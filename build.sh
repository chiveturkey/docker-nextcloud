#!/usr/bin/bash

# Create Docker Nextcloud network.
docker network \
  create \
  -d bridge \
  nextcloud

# Create redis image.
cd redis
./build.sh

# Create mysql image.
cd ../mysql
./build.sh

# Create nextcloud image.
cd ../nextcloud
./build.sh
