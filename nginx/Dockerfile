FROM nginx:1.18

WORKDIR /usr/local/bin
COPY . /usr/local/bin

EXPOSE 80

CMD nginx -c /usr/local/bin/nginx.conf -g "daemon off;"
