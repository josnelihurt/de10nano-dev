FROM alpine:3.7 as downloader
RUN apk add --no-cache wget bash git zip unzip
WORKDIR /
ADD download_packages.sh /download_packages.sh
WORKDIR /downloads
RUN chmod 777 /download_packages.sh;

ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["/download_packages.sh"]