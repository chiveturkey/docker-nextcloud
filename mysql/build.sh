#!/usr/bin/bash

while IFS='=' read -r name value
do
  export $name=${value//\'/}
done < ../etc/nextcloud.config

# Build mysql image.
docker build \
  --no-cache -t mysql .

# Build mysql volume.
docker volume create mysql

# Prepare mysql directory.
docker run \
  --rm \
  --mount type=volume,source=mysql,destination=/var/lib/mysql \
  --name mysql \
  -h mysql \
  mysql \
  /usr/libexec/mariadb-prepare-db-dir

# Change ownership to mysql user.
docker run \
  --rm \
  --mount type=volume,source=mysql,destination=/var/lib/mysql \
  --name mysql \
  -h mysql \
  mysql \
  chown -R mysql:mysql /var/lib/mysql/

# Temporarily enable mysql server.
docker run \
  -d \
  --mount type=volume,source=mysql,destination=/var/lib/mysql \
  --name mysql \
  -h mysql \
  --network=nextcloud \
  mysql \
  /usr/bin/mysqld_safe

# HACKTAG: Should find a better way to do this.
# Give the mysql server time to come up.
sleep 5

# Manually follow steps from mysql_secure_installation.
# Can easily be seen by running `grep do_query /usr/bin/mysql_secure_installation.
docker exec \
  mysql /usr/bin/mysql -u root \
    -e "UPDATE mysql.user SET Password=PASSWORD('$mysql_root_password') WHERE User='root'; FLUSH PRIVILEGES; \
        DELETE FROM mysql.user WHERE User=''; \
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); \
        DROP DATABASE IF EXISTS test; \
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; \
        FLUSH PRIVILEGES;"

# Add nextcloud database and user.
docker exec \
  mysql /usr/bin/mysql -u root --password=$mysql_root_password \
    -e "CREATE DATABASE nextcloud; \
        CREATE USER 'nextcloud'@'nextcloud.nextcloud' IDENTIFIED BY '$mysql_nextcloud_password'; \
        GRANT ALL ON nextcloud.* TO 'nextcloud'@'nextcloud.nextcloud'; \
        GRANT USAGE ON *.* TO 'nextcloud'@'nextcloud.nextcloud';"

# Stop mysql server.
docker exec -it mysql /usr/bin/mysqladmin -u root --password=$mysql_root_password shutdown

# Enable mysql server.
docker container start mysql
