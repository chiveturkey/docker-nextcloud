FROM rockylinux:9.1

ARG nextcloud_url
ARG nextcloud_version

# Install some useful packages, and install missing localhost.crt
RUN dnf install -y bzip2 \
    httpd \
    mod_ssl \
    sudo \
    wget \
    && /usr/libexec/httpd-ssl-gencerts

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

# Install EPEL and Remi, and then install and configure PHP.
RUN dnf install -y \
  https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
  https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm \
  && dnf install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm \
  && dnf install -y php81-php \
  php81-php-bcmath \
  php81-php-gd \
  php81-php-gmp \
  php81-php-intl \
  php81-php-mbstring \
  php81-php-mysqlnd \
  php81-php-opcache \
  php81-php-pecl-apcu \
  php81-php-pecl-imagick-im7 \
  php81-php-pecl-redis5 \
  php81-php-pecl-zip \
  php81-php-process \
  && sed -i -e 's/memory_limit = 128M/memory_limit = 512M/' /etc/opt/remi/php81/php.ini \
  && sed -i -e 's/;opcache.save_comments=1/opcache.save_comments=1/'                       /etc/opt/remi/php81/php.d/10-opcache.ini \
  && sed -i -e 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/'                   /etc/opt/remi/php81/php.d/10-opcache.ini \
  && ln -s /usr/bin/php81 /usr/bin/php

# Install Nextcloud.
RUN wget -nv https://download.nextcloud.com/server/releases/nextcloud-$nextcloud_version.tar.bz2 \
  && wget -nv https://download.nextcloud.com/server/releases/nextcloud-$nextcloud_version.tar.bz2.sha256 \
  && sha256sum -c --ignore-missing nextcloud-$nextcloud_version.tar.bz2.sha256 < nextcloud-$nextcloud_version.tar.bz2 \
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

# Add run.sh to enable both php-fpm and Apache to run simultaneously.
COPY run.sh /run.sh
# TODO: Do I need this, since the source file is already executable?
RUN chmod 755 /run.sh

CMD /run.sh
