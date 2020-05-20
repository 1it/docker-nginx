#!/usr/bin/env bash

# Example parameters

# NGINX_UPSTREAMS="
#   [backend]='
#     \"backend1.example.com weight=5\"
#     \"backend2.example.com:8080 weight=1\"
#   '
#   [frontend]='
#     \"frontend1.example.com weight=1\"
#     \"frontend2.example.com weight=2\"
#   '
# "

# NGINX_SERVER="
#     [SERVER_NAME]='example.com www.example.com'
#     [PORT]='80 default'
#     [SSL]='False'
#     [SSL_CERTIFICATE]=''
#     [SSL_CERTIFICATE_KEY]=''
# "

# NGINX_LOCATIONS="
#   [www]='[NAME]=/www [PROXY_PASS]=http://frontend'
#   [app]='[NAME]=/app [PROXY_PASS]=http://backend'
#   [root]='[NAME]=/ [ROOT]=/var/www'
# "

function upstreams() {
    declare -A UPSTREAMS
    eval "UPSTREAMS=($NGINX_UPSTREAMS)"
    for UPSTREAM in ${!UPSTREAMS[@]}; do
        eval "SERVERS=(${UPSTREAMS[$UPSTREAM]})"
        echo "    upstream ${UPSTREAM} {"
            for SERVER in ${!SERVERS[@]}; do
              echo "      server ${SERVERS[$SERVER]};"
            done
        echo "    }"
        echo ""
    done
}

function server() {
    declare -A SERVER
    declare -A LOCATION
    declare -A LOCATIONS
    eval "SERVER=(${NGINX_SERVER})"
    eval "LOCATIONS=(${NGINX_LOCATIONS})"

    echo "    server {"
    echo "        listen ${SERVER[PORT]};

        server_name ${SERVER[SERVER_NAME]};

        include proxy_params;
    "

    if [ "${SERVER[SSL]}" == 'True' ]; then
        echo -e "        include ssl_params;\n"
        echo -e "        ssl_certificate ${SERVER[SSL_CERTIFICATE]};"
        echo -e "        ssl_certificate_key ${SERVER[SSL_CERTIFICATE_KEY]};\n"
    fi

    for LOC in ${!LOCATIONS[@]}; do
        eval "LOCATION=(${LOCATIONS[$LOC]})"
        echo "        # $LOC"
        echo "        location ${LOCATION[NAME]} {"
        if [ ! -z "${LOCATION[ROOT]}" ]; then
        echo "            root ${LOCATION[ROOT]};"
        fi
        if [ ! -z "${LOCATION[PROXY_PASS]}" ]; then
        echo "            proxy_pass ${LOCATION[PROXY_PASS]};"
        fi
        echo "        }
        "
    done
    if [ "${SERVER[SSL]}" == 'True' ]; then
    echo "        # For Let’s Encrypt HTTP-validation"
    echo "        location ~ /\.well-known/ {"
    echo "            root ${NGINX_WWW_ROOT:-/usr/share/nginx/html};"
    echo "        }"
    fi
    echo "    }"
}

echo "
user  ${NGINX_USER:-nginx};
worker_processes  ${NGINX_WORKER_PROCESSES:-1};

worker_rlimit_nofile ${NGINX_WORKER_RLIMIT_NOFILE:-1024};
timer_resolution ${NGINX_TIMER_RESOLUTION:-100ms};

error_log  ${NGINX_ERROR_LOG_FILE:-/var/log/nginx/error.log} ${NGINX_ERROR_LOG_LEVEL:-warn};
pid        /var/run/nginx.pid;

events {
    worker_connections  ${NGINX_WORKER_CONNECTIONS:-1024};
    multi_accept ${NGINX_MULTI_ACCEPT:-off};
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  ${NGINX_ACCESS_LOG_FILE:-/var/log/nginx/access.log}  ${NGINX_ACCESS_LOG_FORMAT:-main};

    sendfile       ${NGINX_SENDFILE:-on};
    tcp_nopush     ${NGINX_TCP_NOPUSH:-on};
    tcp_nodelay    ${NGINX_TCP_TCP_NODELAY:-on};

    keepalive_timeout  ${NGINX_KEEPALIVE_TIMEOUT:-60};

    types_hash_max_size ${NGINX_TYPES_HASH_MAX_SIZE:-2048};
    server_tokens ${NGINX_SERVER_TOKENS:-on};

    client_header_buffer_size ${NGINX_CLIENT_HEADER_BUFFER_SIZE:-16k};
    large_client_header_buffers ${NGINX_LARGE_CLIENT_HEADER_BUFFERS:-4 16k};

    client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE:-8m};
    client_body_buffer_size ${NGINX_CLIENT_BODY_BUFFER_SIZE:-16k};

    set_real_ip_from  ${NGINX_SET_REAL_IP_FROM:-0.0.0.0/0};
    real_ip_header    ${NGINX_REAL_IP_HEADER:-X-Forwarded-For};
    real_ip_recursive ${NGINX_REAL_IP_RECURSIVE:-off};

    gzip  ${NGINX_GZIP:-on};

    include ${NGINX_DEFAULT_INCLUDE:-/etc/nginx/conf.d/*.conf};

"

upstreams;
server;

echo "}"
