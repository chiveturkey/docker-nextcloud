#!/usr/bin/bash

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < nextcloud.config

docker build \
  --no-cache -t nextcloud .

docker run \
  -d \
  --mount type=volume,source=nextcloud,destination=/nextcloud \
  --name nextcloud \
  -h nextcloud \
  --network=nextcloud \
  -p $nextcloud_ip:80:80 \
  nextcloud

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker ps` or something.
sleep 5

docker exec nextcloud ln -s /nextcloud/config /var/www/html/nextcloud/config
docker exec nextcloud ln -s /nextcloud/data /var/www/html/nextcloud/data

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker ps` or something.
sleep 5

docker container stop -t 30 nextcloud
docker container start nextcloud
