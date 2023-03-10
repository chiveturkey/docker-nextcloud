#!/usr/bin/bash

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

# Get `docker-nextcloud-nextcloud` IP.
docker_nextcloud_nextcloud_ip=$(podman container inspect docker-nextcloud-nextcloud \
                                | jq -r '.[].NetworkSettings.Networks.nextcloud.IPAddress')

# Add nextcloud user with IP.
docker exec \
  docker-nextcloud-mysql /usr/bin/mysql -u root --password=$mysql_root_password \
    -e "CREATE USER 'nextcloud'@'$docker_nextcloud_nextcloud_ip' IDENTIFIED BY '$mysql_nextcloud_password'; \
        GRANT ALL ON nextcloud.* TO 'nextcloud'@'$docker_nextcloud_nextcloud_ip'; \
        GRANT USAGE ON *.* TO 'nextcloud'@'$docker_nextcloud_nextcloud_ip';"
