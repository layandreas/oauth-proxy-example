FROM quay.io/keycloak/keycloak:21.1.1 AS keycloak
FROM python:3.11-slim-buster AS python

# Set environment variables
ENV POETRY_VERSION=${POETRY_VERSION}
ENV POETRY_HOME="/opt/poetry"
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
ENV POETRY_NO_INTERACTION=1

ENV SERVICE_NAME=oauth-secured-app
ENV PATH="$POETRY_HOME/bin:$PATH"
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin

# Install poetry
RUN apt-get update -qqy \
    && apt-get -qqy upgrade \
    && apt-get install -qqy curl \
    && apt-get install -y wget \
    && curl -sSL https://install.python-poetry.org | python3 - \
    # arm64 for Mac with ARM chip
    && wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.4.0/oauth2-proxy-v7.4.0.linux-arm64.tar.gz \
    && tar xvzf oauth2-proxy-v7.4.0.linux-arm64.tar.gz

# Create user + home directory
RUN useradd --create-home --shell /bin/bash --uid 1001 $SERVICE_NAME
COPY . /home/$SERVICE_NAME/app

RUN apt-get install -y default-jre
WORKDIR /home/$SERVICE_NAME/app
RUN poetry install --only main

# Install Keycloak
COPY --from=keycloak /opt/keycloak/ /home/$SERVICE_NAME/app/keycloak/
# Add state: database containing preconfigured realm + user 
ADD h2 /home/$SERVICE_NAME/app/keycloak/data/h2/
RUN ./keycloak/bin/kc.sh build

#COPY --from=keycloak /opt/jboss/ /opt/jboss/

RUN chown -R $SERVICE_NAME /home/$SERVICE_NAME/app
USER $SERVICE_NAME

EXPOSE 4180 8080 8501 8502

ENTRYPOINT ["poetry", "run", "supervisord"]


