# docker-nextcloud

Run NextCloud in CentOS Docker containers.

## How It Works

Beginning with the CentOS minimal Docker image, build images for MySQL, Redis, and the NextCloud application itself.

## How To

* Clone this repository.

* Change directory to the repository.

```
cd /path/to/docker-nextcloud
```

* Create `etc/nextcloud.config`.  `etc/nextcloud.config.example` is provided for reference, but SHOULD NOT be used.

* Run the master `build.sh` shell script.

```
./build.sh
```
