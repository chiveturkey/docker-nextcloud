#!/usr/bin/bash

/opt/remi/php81/root/usr/sbin/php-fpm -D
exec /usr/sbin/httpd -DFOREGROUND
