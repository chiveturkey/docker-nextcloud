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

* Create a secondary IP on the host machine for your Nextcloud Docker instance to bind to.  The exact command will depend on your system.  If you are using `NetworkManager`, it might be something like this.

```
nmcli connection modify enp1s0 +ipv4.addresses "192.168.100.1/24"
```

* Run the master `build.sh` shell script.

```
./build.sh
```

## Podman Storage Considerations

If using Podman instead of Docker and further running 1) in non-root mode and 2) with SELinux Enforcing, then you have to do some extra work for external storage permissions.  First, you need the mapped `uid` for your user inside of the Podman container and second, you need to set the SELinux context on the mount.  Example:

```
//192.168.100.1/files    /nas/files                                 cifs    credentials=/root/.smbcredentials,uid=100001,gid=1000,context="system_u:object_r:container_file_t:s0",noauto 0 0
```
