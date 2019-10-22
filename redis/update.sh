#!/usr/bin/bash

# Ensure container is stopped and deleted before updating.
docker container stop docker-nextcloud-redis
docker container rm docker-nextcloud-redis
docker image rm docker-nextcloud-redis

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

docker build \
  --no-cache -t docker-nextcloud-redis .

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker image ls` or something.
sleep 5

# Start Redis server.
docker run \
  -d \
  --name docker-nextcloud-redis \
  -h redis \
  --network=nextcloud \
  docker-nextcloud-redis
