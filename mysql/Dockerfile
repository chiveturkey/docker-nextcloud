FROM centos:7

# Update and install some useful packages.
RUN yum update -y && \
  yum install -y \
    wget

# Retrieve MariaDB repo GPG key.
RUN wget https://downloads.mariadb.com/MariaDB/MariaDB-Server-GPG-KEY > /etc/pki/rpm-gpg/MariaDB-Server-GPG-KEY

# Copy over MariaDB repo file.
COPY mariadb.repo /etc/yum.repos.d/

# Install MariaDB.
RUN yum install -y \
  MariaDB-client \
  MariaDB-server

# Copy over Nextcloud-specific MySQL requirements.
COPY nextcloud.cnf /etc/my.cnf.d

# Setup mysql user.
RUN export uid=27 gid=27 && \
  echo "mysql:x:${uid}:${gid}:MariaDB Server:/var/lib/mysql:/sbin/nologin" >> /etc/passwd && \
  echo "mysql:x:${uid}:" >> /etc/group

CMD /usr/bin/mysqld_safe
