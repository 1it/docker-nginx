#!/usr/bin/env bash

# NGINX_UPSTREAMS="
#   [backend]='
#     \"backend1.example.com weight=5\"
#     \"backend2.example.com:8080 weight=1\"
#     \"unix:/tmp/backend3 weight=5\"
#   '
#   [frontend]='
#     \"frontend1.example.com weight=1\"
#     \"frontend2.example.com weight=2\"
#   '
# "

# NGINX_SERVERS="
#   [default]='
#     [SERVER_NAME]=\"example.com www.example.com\"
#     [PORT]=\"8080\"
#   '
#   [test]='
#     [SERVER_NAME]=\"example.com www.example.com\"
#     [PORT]=\"8180\"
#   '
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

function servers() {
    declare -A SERVERS
    declare -A SERVER
    declare -A LOCATIONS
    declare -A LOCATION
    eval "SERVERS=($NGINX_SERVERS)"
    eval "LOCATIONS=(${NGINX_LOCATIONS})"

    for SRV in ${!SERVERS[@]}; do
        eval "SERVER=(${SERVERS[$SRV]})"
        echo "    server {"
        echo "        listen ${SERVER[PORT]};

        server_name ${SERVER[SERVER_NAME]};

        include proxy_params;
        "
        if [ ! -z "$NGINX_SSL_CERTIFICATE" ] && [ ! -z "$NGINX_SSL_CERTIFICATE_KEY" ]; then
            echo -e "        include ssl_params;\n"
            echo -e "        ssl_certificate ${NGINX_SSL_CERTIFICATE};"
            echo -e "        ssl_certificate_key ${NGINX_SSL_CERTIFICATE_KEY};\n"
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
        if [ ! -z "$NGINX_SSL_CERTIFICATE" ] && [ ! -z "$NGINX_SSL_CERTIFICATE_KEY" ]; then
        echo "        # For Let’s Encrypt HTTP-validation"
        echo "        location ~ /\.well-known/ {"
        echo "            root ${NGINX_WWW_ROOT:-/usr/share/nginx/html};"
        echo "        }"
        fi
    echo "    }
    "
    done
}

echo "
user  ${NGINX_USER:-nginx};
worker_processes  ${NGINX_WORKER_PROCESSES:-1};

error_log  ${NGINX_ERROR_LOG_FILE:-/var/log/nginx/error.log} ${NGINX_ERROR_LOG_LEVEL:-warn};
pid        /var/run/nginx.pid;

events {
    worker_connections  ${NGINX_WORKER_CONNECTIONS:-1024};
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  ${NGINX_ACCESS_LOG_FILE:-/var/log/nginx/access.log}  ${NGINX_ACCESS_LOG_TYPE:-main};

    sendfile       ${NGINX_SENDFILE:-on};
    tcp_nopush     ${NGINX_TCP_NOPUSH:-off};

    keepalive_timeout  ${NGINX_KEEPALIVE_TIMEOUT:-65};

    gzip  ${NGINX_GZIP:-on};

    include /etc/nginx/conf.d/*.conf;

"

upstreams;
servers;

echo "}"
