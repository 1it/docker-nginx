#!/usr/bin/env bash

if [ -z "$NGINX_SSL_DHPARAM_PATH" ]; then
    export NGINX_SSL_DHPARAM_PATH=/etc/ssl/certs/dhparam.pem
fi

if [ ! -z "$NGINX_SSL_DHPARAM_BITS" ]; then
    mkdir -p /etc/ssl/certs/
    openssl dhparam -out ${NGINX_SSL_DHPARAM_PATH} ${NGINX_SSL_DHPARAM_BITS:-2048}
fi

echo "
ssl_session_timeout ${NGINX_SSL_SESSION_TIMEOUT:-1d};
ssl_session_cache ${NGINX_SSL_SESSION_CACHE:-shared:SSL:10m};
ssl_session_tickets ${NGINX_SSL_SESSION_TICKETS:-off};
"

if [ ! -z "$NGINX_SSL_DHPARAM_BITS" ]; then echo "ssl_dhparam ${NGINX_SSL_DHPARAM_PATH};"; fi

echo "ssl_protocols ${NGINX_SSL_PROTOCOLS:-TLSv1.2 TLSv1.3};
ssl_ciphers ${NGINX_SSL_CIPHERS:-ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384};
ssl_prefer_server_ciphers ${NGINX_SSL_PREFER_SERVER_CIPHERS:-off};

add_header Strict-Transport-Security \"max-age=63072000\" always;

ssl_stapling ${NGINX_SSL_STAPLING:-on};
ssl_stapling_verify ${NGINX_SSL_STAPLING_VERIFY:-on};
"