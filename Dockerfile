FROM nginx:latest

LABEL maintainer="Ivan Tuzhilkin <ivan.tuzhilkin@gmail.com>"

COPY $PWD/entrypoint.sh /
COPY $PWD/templates /etc/nginx/templates

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
