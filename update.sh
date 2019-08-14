#!/usr/bin/bash

# Master update script.

# Fail if 'etc/nextcloud.config' is not present.
if [[ ! -f etc/nextcloud.config ]] ; then
    echo "File 'etc/nextcloud.config' is not present.  Aborting."
    exit
fi

# Stop services.
docker container stop docker-nextcloud-nextcloud
docker container stop docker-nextcloud-mysql
docker container stop docker-nextcloud-redis

# Create redis image.
cd redis
./update.sh

# Create mysql image.
cd ../mysql
./update.sh

# Create nextcloud image.
cd ../nextcloud
./update.sh
