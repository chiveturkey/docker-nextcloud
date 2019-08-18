#!/usr/bin/bash

# Ensure container is stopped and deleted before updating.
docker container stop docker-nextcloud-nextcloud
docker container rm docker-nextcloud-nextcloud

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

docker build \
  --build-arg nextcloud_version=$nextcloud_version \
  --no-cache -t docker-nextcloud-nextcloud .

# Setup external storage mount if 'use_external_storage' is 'true'.
if [ "$use_external_storage" = 'true' ]; then
  docker run \
    -d \
    --mount type=volume,source=docker-nextcloud-nextcloud,destination=/nextcloud \
    --mount type=bind,source=$external_storage_directory,destination=/externalstorage \
    --name docker-nextcloud-nextcloud \
    -h nextcloud \
    --network=nextcloud \
    -p $nextcloud_ip:80:80 \
    -p $nextcloud_ip:443:443 \
    docker-nextcloud-nextcloud
else
  docker run \
    -d \
    --mount type=volume,source=docker-nextcloud-nextcloud,destination=/nextcloud \
    --name docker-nextcloud-nextcloud \
    -h nextcloud \
    --network=nextcloud \
    -p $nextcloud_ip:80:80 \
    -p $nextcloud_ip:443:443 \
    docker-nextcloud-nextcloud
fi

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker ps` or something.
sleep 5

# Link up volume in container.
docker exec docker-nextcloud-nextcloud bash -c " \
  ln -s /nextcloud/config /var/www/html/nextcloud/config \
  && ln -s /nextcloud/data /var/www/html/nextcloud/data"

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker ps` or something.
sleep 5

docker container stop -t 30 docker-nextcloud-nextcloud
docker container start docker-nextcloud-nextcloud
