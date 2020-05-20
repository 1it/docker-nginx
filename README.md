# Nginx Docker image
  
Nginx Docker image with example configuration managed via environment variables.  
*Testing only-usage*  

### Current versions:  
*Current tags:* [`latest`](https://github.com/1it/docker-nginx/blob/master/Dockerfile)  
Based on `nginx:latest`.  

### Defaults  
Default `nginx.conf` parameters that can be changed within `environment`.  
```sh
NGINX_USER=nginx
NGINX_WORKER_PROCESSES=1
NGINX_WORKER_RLIMIT_NOFILE=1024
NGINX_TIMER_RESOLUTION=100ms
NGINX_WORKER_CONNECTIONS=1024
NGINX_MULTI_ACCEPT=off
NGINX_ACCESS_LOG_FILE=/var/log/nginx/access.log
NGINX_ACCESS_LOG_FORMAT=main
NGINX_ERROR_LOG_FILE=/var/log/nginx/error.log
NGINX_ERROR_LOG_LEVEL=warn
NGINX_SENDFILE=on
NGINX_TCP_NOPUSH=on
NGINX_TCP_TCP_NODELAY=on
NGINX_KEEPALIVE_TIMEOUT=60
NGINX_TYPES_HASH_MAX_SIZE=2048
NGINX_SERVER_TOKENS=on
NGINX_CLIENT_HEADER_BUFFER_SIZE=16k
NGINX_LARGE_CLIENT_HEADER_BUFFERS=4
NGINX_CLIENT_MAX_BODY_SIZE=8m
NGINX_CLIENT_BODY_BUFFER_SIZE=16k
NGINX_SET_REAL_IP_FROM=0.0.0.0/0
NGINX_REAL_IP_HEADER=X-Forwarded-For
NGINX_REAL_IP_RECURSIVE=off
NGINX_GZIP=on
NGINX_DEFAULT_INCLUDE=/etc/nginx/conf.d/*.conf
```
`NGINX_REMOVE_DEFAULT_CONF` - if not set, by default removes default nginx server configuration from `/etc/nginx/conf.d/default.conf` before Nginx starts. Use `NGINX_REMOVE_DEFAULT_CONF=False` to avoid removing this file.

### Example server configuration
```yaml
NGINX_UPSTREAMS: |
  [test1]='"http-echo-test1:8080"
           "http-echo-test2:8181 weight=3"'
  [test2]='"http-echo-test2:8181 weight=1"'
NGINX_SERVER: |
  [SERVER_NAME]='example.com www.example.com'
  [PORT]='80'
NGINX_LOCATIONS: |
  [test1]='[NAME]=/test1
           [PROXY_PASS]=http://test1'
  [test2]='[NAME]=/test2
           [PROXY_PASS]=http://test2'
  [def]='[NAME]=/
         [ROOT]=/usr/share/nginx/html'
```
### Server with ssl
```yaml
NGINX_SERVER: |
  [SERVER_NAME]='example.com www.example.com'
  [PORT]='443 ssl default'
  [SSL]='True'
  [SSL_CERTIFICATE]='/etc/ssl/cert.pem'
  [SSL_CERTIFICATE_KEY]='/etc/ssl/key.pem'
```
