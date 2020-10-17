FROM alpine:3.7 as downloader
RUN apk add --no-cache wget bash git
WORKDIR /
ADD download_packages.sh /download_packages.sh
WORKDIR /downloads
RUN chmod 777 /download_packages.sh;

ENTRYPOINT ["/bin/bash"]

FROM nginx as http
COPY ./nginx.config /etc/nginx/nginx.conf