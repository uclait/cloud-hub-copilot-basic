# Base image (Alpine Linux with nginx installed.)
FROM nginx:alpine

# Copy our static site to the nginx www root.
COPY /html/. /usr/share/nginx/html

EXPOSE 80