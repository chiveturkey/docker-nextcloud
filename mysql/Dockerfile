FROM rockylinux:9.1

# Update and install some useful packages.
RUN dnf update -y && \
  dnf install -y \
    mariadb-server

# Copy over Nextcloud-specific MySQL requirements.
COPY nextcloud.cnf /etc/my.cnf.d

CMD /usr/bin/mysqld_safe
