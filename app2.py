import streamlit as st
from streamlit.web.server.websocket_headers import _get_websocket_headers
import urllib.parse
import jwt

st.header("Hello App2")

# Header 
headers = _get_websocket_headers()

st.write("Request headers:")
st.write(headers)

access_token = headers.get("X-Access-Token")


sign_out_url_oauth_proxy = "http://localhost/oauth2/sign_out"
# Must be set as a valid post redirect URI in your Keycloak client settings for your realm
sign_out_url_keycloak = "http://localhost:8080/realms/myrealm/protocol/openid-connect/logout"
sign_out_url_oauth_proxy_encoded = urllib.parse.quote(sign_out_url_oauth_proxy)

# Use Keycloak sign out page, then make Keycloak redirect to oauth proxy sign out page 
# to clear oauth proxy's cookie
sign_out_url_oauth_proxy_and_keycloak = f"{sign_out_url_keycloak}?post_logout_redirect_uri={sign_out_url_oauth_proxy_encoded}&client_id=myclient"

with st.sidebar:
    st.write(
        f'<a href="{sign_out_url_oauth_proxy_and_keycloak}" target="_self">Logout</a>', 
        unsafe_allow_html=True
    )

st.write("Decoded JWT passed from oauth2-proxy in request header:")
payload = jwt.decode(
    access_token.encode("utf-8"),
    options={"verify_signature": False})
st.write(payload)
