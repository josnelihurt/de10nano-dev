#!/bin/sh

#This script will need to be ran before building the main image for the builder, 
#but it will donwload the files in ./downloader/downloads, if you have the files listed in 
#./downloader/build/download_packages go a copy it into ./downloader/downloads and 
#the ./downloader/run.sh will ommit to download, if any one to improve this downloader use a hash for
#those files but I don't have enoght time for that at this moment, also It will create an http server in your main machine
#so you can easily share those files within your LAN
./downloader/run.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

#this will build the main builder image
docker-compose build

#To connect to the main server use nxclient on the configured port by default 4400,
#why this port? and not the standart 4000, cause I also have a nxserver on my local machine :P
docker-compose up -d