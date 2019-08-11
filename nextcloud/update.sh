#!/usr/bin/bash

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < nextcloud.config

docker build \
  --no-cache -t docker-nextcloud-nextcloud .

docker run \
  -d \
  --mount type=volume,source=docker-nextcloud-nextcloud,destination=/nextcloud \
  --name docker-nextcloud-nextcloud \
  -h nextcloud \
  --network=nextcloud \
  -p $nextcloud_ip:80:80 \
  docker-nextcloud-nextcloud

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker ps` or something.
sleep 5

docker exec docker-nextcloud-nextcloud ln -s /nextcloud/config /var/www/html/nextcloud/config
docker exec docker-nextcloud-nextcloud ln -s /nextcloud/data /var/www/html/nextcloud/data

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker ps` or something.
sleep 5

docker container stop -t 30 docker-nextcloud-nextcloud
docker container start docker-nextcloud-nextcloud
