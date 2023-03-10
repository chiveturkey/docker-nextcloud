#!/usr/bin/bash

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

# Set default values if variables not present.
nextcloud_url="${nextcloud_url:-nextcloud.test}"
nextcloud_version="${nextcloud_version:-21.0.7}"

# Link up volume in container.
docker exec docker-nextcloud-nextcloud bash -c " \
  mkdir /nextcloud/config \
  && mkdir /nextcloud/data \
  && chown -R apache:apache /nextcloud \
  && ln -s /nextcloud/config /var/www/html/nextcloud/config \
  && ln -s /nextcloud/data /var/www/html/nextcloud/data"

# Create initial config.php, and allow local symlinks.
docker exec docker-nextcloud-nextcloud bash -c "
  cat << EOF > /nextcloud/config/config.php
<?php
\\\$CONFIG = array (
  'localstorage.allowsymlinks' => true,
);
EOF"
docker exec docker-nextcloud-nextcloud bash -c "chown apache:apache /nextcloud/config/config.php"

# Nextcloud configuration settings.
docker exec docker-nextcloud-nextcloud sudo -u apache php /var/www/html/nextcloud/occ maintenance:install --database 'mysql' --database-host 'docker-nextcloud-mysql' --database-name 'nextcloud' --database-user 'nextcloud' --database-pass $mysql_nextcloud_password --admin-user $nextcloud_admin_user --admin-pass $nextcloud_admin_password --data-dir '/var/www/html/nextcloud/data'
docker exec docker-nextcloud-nextcloud sudo -u apache php /var/www/html/nextcloud/occ config:system:set trusted_domains 1 --value=$nextcloud_url

# Add Memcached/Redis
docker exec docker-nextcloud-nextcloud bash -c " \
  sed -i '$ d' /var/www/html/nextcloud/config/config.php \
  && echo \"  'memcache.locking' => '\OC\Memcache\Redis',\" >> /var/www/html/nextcloud/config/config.php \
  && echo \"  'memcache.local' => '\OC\Memcache\Redis',\"   >> /var/www/html/nextcloud/config/config.php \
  && echo \"  'redis' => array(\"                           >> /var/www/html/nextcloud/config/config.php \
  && echo \"    'host' => 'docker-nextcloud-redis',\"       >> /var/www/html/nextcloud/config/config.php \
  && echo \"    'port' => 6379,\"                           >> /var/www/html/nextcloud/config/config.php \
  && echo \"  ),\"                                          >> /var/www/html/nextcloud/config/config.php \
  && echo \"  'default_phone_region' => 'US',\"             >> /var/www/html/nextcloud/config/config.php \
  && echo \");\"                                            >> /var/www/html/nextcloud/config/config.php"

# Setup external storage mount if 'use_external_storage' is 'true'.
if [ "$use_external_storage" = 'true' ]; then
  docker exec docker-nextcloud-nextcloud sudo -u apache php /var/www/html/nextcloud/occ app:enable files_external
  docker exec docker-nextcloud-nextcloud sudo -u apache php /var/www/html/nextcloud/occ files_external:create \
    -c datadir=/externalstorage \
    Photos \
    local \
    null::null
fi

# Setup trusted_proxies if 'use_reverse_proxy' is 'true'.
if [ "$use_reverse_proxy" = 'true' ]; then
  docker exec docker-nextcloud-nextcloud sudo -u apache php /var/www/html/nextcloud/occ config:system:set trusted_proxies 0 --value=$reverse_proxy_ip
fi

# Put .htaccess and config.php.sample back in place.
docker exec docker-nextcloud-nextcloud bash -c " \
  cp /tmp/.htaccess /tmp/config.sample.php /var/www/html/nextcloud/config \
  && chown -R apache:apache /var/www/html/nextcloud/config \
  && rm -f /tmp/.htaccess /tmp/config.sample.php"

# TODO: HACKTAG: There's some sort of race condition that causes this to fail if it executes too
# soon.  It would be better to watch output from `docker ps` or something.
sleep 5

docker container stop -t 30 docker-nextcloud-nextcloud
docker container start docker-nextcloud-nextcloud
