FROM nginx:alpine
LABEL org.opencontainers.image.title="solbao-custom-web"
ENV APP_ENV=dev
COPY src/ /usr/share/nginx/html/
