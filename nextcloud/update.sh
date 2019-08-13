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

# Link up volume in container.
docker exec docker-nextcloud-nextcloud bash -c " \
  ln -s /nextcloud/config /var/www/html/nextcloud/config \
  && ln -s /nextcloud/data /var/www/html/nextcloud/data"

# Tune PHP settings.
docker exec docker-nextcloud-nextcloud bash -c " \
  sed -i -e 's/memory_limit = 128M/memory_limit = 512M/'                                   /etc/opt/rh/rh-php72/php.ini \
  && sed -i -e 's/opcache.max_accelerated_files=4000/opcache.max_accelerated_files=10000/' /etc/opt/rh/rh-php72/php.d/10-opcache.ini \
  && sed -i -e 's/;opcache.save_comments=1/opcache.save_comments=1/'                       /etc/opt/rh/rh-php72/php.d/10-opcache.ini \
  && sed -i -e 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/'                   /etc/opt/rh/rh-php72/php.d/10-opcache.ini"

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker ps` or something.
sleep 5

docker container stop -t 30 docker-nextcloud-nextcloud
docker container start docker-nextcloud-nextcloud
