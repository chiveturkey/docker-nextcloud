#!/usr/bin/bash

# Master build script.

# Fail if 'etc/nextcloud.config' is not present.
if [[ ! -f etc/nextcloud.config ]] ; then
    echo "File 'etc/nextcloud.config' is not present.  Aborting."
    exit
fi

# Create Docker Nextcloud network.
docker network \
  create \
  -d bridge \
  nextcloud

# Create redis image.
cd redis
./build.sh

# Create mysql image.
cd ../mysql
./build.sh

# Create nextcloud image.
cd ../nextcloud
./build.sh
