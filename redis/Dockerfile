FROM centos:7

# Update and install some useful packages.
RUN yum install epel-release -y \
  && yum update -y \
  && yum install -y redis

RUN sed -i 's/^bind/#bind/' /etc/redis.conf \
  && sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis.conf

CMD /usr/bin/redis-server /etc/redis.conf
