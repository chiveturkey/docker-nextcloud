#!/usr/bin/bash

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

docker build \
  --no-cache -t redis .

docker run \
  -d \
  --name redis \
  -h redis \
  --network=nextcloud \
  redis
