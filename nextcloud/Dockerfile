FROM centos:7

ARG nextcloud_url
ARG nextcloud_version

# Update and install some useful packages.
RUN yum update -y && \
  yum install -y bzip2 \
    centos-release-scl \
    httpd \
    mod_ssl \
    sudo \
    wget

# Create default vhost content.
RUN mkdir /var/www/html/default
COPY index.html /var/www/html/default

# Copy vhost definitions.
COPY 00-default.conf nextcloud.conf /etc/httpd/conf.d/

# Replace $nextcloud_url in vhost definition (or do nothing if the value is the default).
RUN sed -i "s/nextcloud.test/$nextcloud_url/" /etc/httpd/conf.d/nextcloud.conf

# Setup SSL.
COPY $nextcloud_url.crt /etc/pki/tls/certs
COPY $nextcloud_url.key /etc/pki/tls/private

# Install and configure PHP.
RUN yum install -y rh-php73 \
  rh-php73-php \
  rh-php73-php-bcmath \
  rh-php73-php-gd \
  rh-php73-php-gmp \
  rh-php73-php-imagick \
  rh-php73-php-intl \
  rh-php73-php-mbstring \
  rh-php73-php-mysqlnd \
  rh-php73-php-opcache \
  rh-php73-php-pecl-apcu \
  rh-php73-php-pecl-redis \
  && ln -s /opt/rh/httpd24/root/etc/httpd/conf.d/rh-php73-php.conf /etc/httpd/conf.d/ \
  && ln -s /opt/rh/httpd24/root/etc/httpd/conf.modules.d/15-rh-php73-php.conf /etc/httpd/conf.modules.d/ \
  && ln -s /opt/rh/httpd24/root/etc/httpd/modules/librh-php73-php7.so /etc/httpd/modules/ \
  && ln -s /opt/rh/rh-php73/root/bin/php /usr/bin/php \
  && sed -i -e 's/memory_limit = 128M/memory_limit = 512M/'                                /etc/opt/rh/rh-php73/php.ini \
  && sed -i -e 's/opcache.max_accelerated_files=4000/opcache.max_accelerated_files=10000/' /etc/opt/rh/rh-php73/php.d/10-opcache.ini \
  && sed -i -e 's/;opcache.save_comments=1/opcache.save_comments=1/'                       /etc/opt/rh/rh-php73/php.d/10-opcache.ini \
  && sed -i -e 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/'                   /etc/opt/rh/rh-php73/php.d/10-opcache.ini

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
