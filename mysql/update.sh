#!/usr/bin/bash

# Ensure container is stopped and deleted before updating.
docker container stop docker-nextcloud-mysql
docker container rm docker-nextcloud-mysql

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

# Build docker-nextcloud-mysql image.
docker build \
  --no-cache -t docker-nextcloud-mysql .

# Enable mysql server.
docker run \
  -d \
  --mount type=volume,source=docker-nextcloud-mysql,destination=/var/lib/mysql \
  --name docker-nextcloud-mysql \
  -h mysql \
  --network=nextcloud \
  docker-nextcloud-mysql
