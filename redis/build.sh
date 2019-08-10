#!/usr/bin/bash

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

docker build \
  --no-cache -t docker-nextcloud-redis .

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker image ls` or something.
sleep 5

docker run \
  -d \
  --name docker-nextcloud-redis \
  -h redis \
  --network=nextcloud \
  docker-nextcloud-redis
