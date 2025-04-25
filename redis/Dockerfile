FROM rockylinux:9.1

# Update and install some useful packages.
RUN dnf update -y \
  && dnf install -y redis

RUN sed -i 's/^bind/#bind/' /etc/redis/redis.conf \
  && sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf

CMD /usr/bin/redis-server /etc/redis/redis.conf
