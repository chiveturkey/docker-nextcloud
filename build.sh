#!/usr/bin/bash

# Create Docker Nextcloud network.
docker network \
  create \
  -d bridge \
  nextcloud

# Create nextcloud image.
cd nextcloud
./build.sh
