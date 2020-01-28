FROM nginx:latest
EXPOSE 80
COPY ./index.html /helloworld-storage/
COPY ./nginx.conf /etc/nginx/nginx.conf
ENV NGINX_PORT=80
ENTRYPOINT [ "/bin/bash" ,"-c", "exec nginx -g 'daemon off;'"]