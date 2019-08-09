#!/usr/bin/bash

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

# Build nextcloud image.
docker build \
  --no-cache -t nextcloud .

# Build nextcloud volume.
docker volume create nextcloud

# Temporarily enable nextcloud application.
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

# Link up volume in container.
docker exec nextcloud bash -c " \
  mkdir /nextcloud/config \
  && mkdir /nextcloud/data \
  && chown -R apache:apache /nextcloud \
  && ln -s /nextcloud/config /var/www/html/nextcloud/config \
  && ln -s /nextcloud/data /var/www/html/nextcloud/data"

# Nextcloud configuration settings.
docker exec nextcloud sudo -u apache php /var/www/html/nextcloud/occ maintenance:install --database 'mysql' --database-host 'mysql' --database-name 'nextcloud' --database-user 'nextcloud' --database-pass $mysql_nextcloud_password --admin-user $nextcloud_admin_user --admin-pass $nextcloud_admin_password --data-dir '/var/www/html/nextcloud/data'
docker exec nextcloud sudo -u apache php /var/www/html/nextcloud/occ config:system:set trusted_domains 1 --value=$nextcloud_url

# Add Memcached/Redis
docker exec nextcloud bash -c " \
  sed -i '$ d' /var/www/html/nextcloud/config/config.php \
  && echo \"  'memcache.locking' => '\OC\Memcache\Redis',\" >> /var/www/html/nextcloud/config/config.php \
  && echo \"  'memcache.local' => '\OC\Memcache\Redis',\"   >> /var/www/html/nextcloud/config/config.php \
  && echo \"      'redis' => array(\"                       >> /var/www/html/nextcloud/config/config.php \
  && echo \"        'host' => 'redis',\"                    >> /var/www/html/nextcloud/config/config.php \
  && echo \"        'port' => 6379,\"                       >> /var/www/html/nextcloud/config/config.php \
  && echo \"      ),\"                                      >> /var/www/html/nextcloud/config/config.php \
  && echo \");\"                                            >> /var/www/html/nextcloud/config/config.php"

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker ps` or something.
sleep 5

docker container stop -t 30 nextcloud
docker container start nextcloud
