FROM centos:7

ARG nextcloud_version

# Update and install some useful packages.
RUN yum update -y && \
  yum install -y bzip2 \
    centos-release-scl \
    httpd \
    sudo \
    wget

# Create default vhost content.
RUN mkdir /var/www/html/default
COPY index.html /var/www/html/default

# Copy vhost definitions.
COPY 00-default.conf nextcloud.conf /etc/httpd/conf.d/

# Install PHP.
RUN yum install -y rh-php72 \
  rh-php72-php \
  rh-php72-php-gd \
  rh-php72-php-mbstring \
  rh-php72-php-intl \
  rh-php72-php-pecl-apcu \
  rh-php72-php-mysqlnd \
  rh-php72-php-pecl-redis \
  rh-php72-php-opcache \
  rh-php72-php-imagick \
  && ln -s /opt/rh/httpd24/root/etc/httpd/conf.d/rh-php72-php.conf /etc/httpd/conf.d/ \
  && ln -s /opt/rh/httpd24/root/etc/httpd/conf.modules.d/15-rh-php72-php.conf /etc/httpd/conf.modules.d/ \
  && ln -s /opt/rh/httpd24/root/etc/httpd/modules/librh-php72-php7.so /etc/httpd/modules/ \
  && ln -s /opt/rh/rh-php72/root/bin/php /usr/bin/php

# Install Nextcloud.
RUN wget -nv https://download.nextcloud.com/server/releases/nextcloud-$nextcloud_version.tar.bz2 \
  && wget -nv https://download.nextcloud.com/server/releases/nextcloud-$nextcloud_version.tar.bz2.sha256 \
  && sha256sum -c nextcloud-$nextcloud_version.tar.bz2.sha256 < nextcloud-$nextcloud_version.tar.bz2 \
  && wget -nv https://download.nextcloud.com/server/releases/nextcloud-$nextcloud_version.tar.bz2.asc \
  && wget -nv https://nextcloud.com/nextcloud.asc \
  && gpg --import nextcloud.asc \
  && gpg --verify nextcloud-$nextcloud_version.tar.bz2.asc nextcloud-$nextcloud_version.tar.bz2 \
  && tar -xjvf nextcloud-$nextcloud_version.tar.bz2 -C /var/www/html \
  && cp /var/www/html/nextcloud/config/config.sample.php /var/www/html/nextcloud/config/.htaccess /tmp \
  && rm -rf /var/www/html/nextcloud/config \
  && chown -R apache:apache /var/www/html/nextcloud \
  && mkdir /nextcloud \
  && chown -R apache:apache /nextcloud

CMD /usr/sbin/httpd -DFOREGROUND
