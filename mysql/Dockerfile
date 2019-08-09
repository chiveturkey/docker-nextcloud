FROM centos:7

# Update and install some useful packages.
RUN yum update -y && \
  yum install -y \
    mariadb \
    mariadb-server

# Setup mysql user.
RUN export uid=27 gid=27 && \
  echo "mysql:x:${uid}:${gid}:MariaDB Server:/var/lib/mysql:/sbin/nologin" >> /etc/passwd && \
  echo "mysql:x:${uid}:" >> /etc/group

CMD /usr/bin/mysqld_safe
