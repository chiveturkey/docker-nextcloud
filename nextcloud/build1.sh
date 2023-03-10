#!/usr/bin/bash

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

# Set default values if variables not present.
nextcloud_url="${nextcloud_url:-nextcloud.test}"
nextcloud_version="${nextcloud_version:-21.0.7}"

# Create self-signed SSL certs.
openssl req \
  -new \
  -newkey rsa:4096 \
  -x509 \
  -sha256 \
  -days 3650 \
  -nodes \
  -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=$nextcloud_url" \
  -out $nextcloud_url.crt \
  -keyout $nextcloud_url.key \
  && chmod 600 $nextcloud_url.crt $nextcloud_url.key

# Build docker-nextcloud-nextcloud image.
docker build \
  --build-arg nextcloud_url=$nextcloud_url \
  --build-arg nextcloud_version=$nextcloud_version \
  --no-cache -t docker-nextcloud-nextcloud .

# Build docker-nextcloud-nextcloud volume.
docker volume create docker-nextcloud-nextcloud

# Temporarily enable nextcloud application.
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
