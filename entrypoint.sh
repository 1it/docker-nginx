#!/usr/bin/env bash

# Invoke template scripts
/etc/nginx/templates/nginx.conf.tpl.sh > /etc/nginx/nginx.conf
/etc/nginx/templates/proxy_params.tpl.sh > /etc/nginx/proxy_params
/etc/nginx/templates/ssl_params.tpl.sh > /etc/nginx/ssl_params

# Remove default.conf
if [ "${NGINX_REMOVE_DEFAULT_CONF}" != 'False' ]; then
    rm -f /etc/nginx/conf.d/default.conf
fi

exec "$@"