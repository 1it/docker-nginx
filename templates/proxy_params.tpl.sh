#!/usr/bin/env bash

echo "
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Request-Scheme \$http_x_request_scheme;

proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;

proxy_connect_timeout  ${NGINX_PROXY_CONNECT_TIMEOUT:-60};
proxy_send_timeout     ${NGINX_PROXY_SEND_TIMEOUT:-60};
proxy_read_timeout     ${NGINX_PROXY_READ_TIMEOUT:-60};
"