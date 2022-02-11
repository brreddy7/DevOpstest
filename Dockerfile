FROM nginx:latest
EXPOSE 80 443
COPY index.html /usr/share/nginx/html/
