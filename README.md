# Snapraid in Docker  
originally forked from the following repos, please check them out!  
https://github.com/linuxserver-archive/docker-snapraid  
https://github.com/xagaba/snapraid  


This is container uses the latest alpine container to compile snapraid from source and combines it with the latest snapraid-runner.py script.
These are the source repos for more info:  
https://github.com/amadvance/snapraid  
https://github.com/Chronial/snapraid-runner  



## Usage

This container is configured using two files `snapraid.conf` and `snapraid-runner.conf`. These should both be placed into your hosts local config directory to be mounted as a volume **before** the container is executed for the first time.

```
version: '3.8'

services:
  app:
    image: fred92/snapraid:master
    restart: always
    privileged: true
    volumes:
      - type: bind
        source: /dev/disk
        target: /dev/disk
      - /mnt:/mnt
      - config:/config
    environment:
       - PGID=1000
       - GUID=1000

volumes:
  config:
```

**Parameters**
* `-v /mnt` - The location of your data disks, a good convention is `/mnt/disk*` for your data drives
* `-v /config` - The location of the Snapraid and SnapRAID-runner configurations
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation

It is based on phusion-baseimage with ssh removed, for shell access whilst the container is running do `docker exec -it snapraid /bin/bash`.

### Detecting move operations
You'll probably notice when snapraid runs it gives a warning like `WARNING! UUID is unsupported for disks` and it may not detect moved files. Instead it seems them as copied and removed. In order to detect the file moves you can run with the following additional paramters.

```
--privileged --mount type=bind,source=/dev/disk,target=/dev/disk
```

* `--privileged` will share all your devices (ie `/dev/sdb`, `/dev/sdb1`, etc) with your container. Alternatively, you could probably use something like `--device /dev/sdb:/dev/sdb --device /dev/sdb1:/dev/sdb1`, but you'd need to do it for each drive you have setup.
* `--mount type=bind,source=/dev/disk,target=/dev/disk` mounts the disk listing into the container, so snapraid can run something like `ls /dev/disk/by-uuid` to get a list of all the disks by UUID

### User / Group Identifiers

**TL;DR** - The `PGID` and `PUID` values set the user / group you'd like your container to 'run as' to the host OS. This can be a user you've created or even root (not recommended).

Part of what makes our containers work so well is by allowing you to specify your own `PUID` and `PGID`. This avoids nasty permissions errors with relation to data volumes (`-v` flags). When an application is installed on the host OS it is normally added to the common group called users, Docker apps due to the nature of the technology can't be added to this group. So we added this feature to let you easily choose when running your containers.

## Setting up the application

SnapRAID has a comprehensive manual available [here](http://www.snapraid.it/). Any SnapRAID command can be executed from the host easily using `docker exec -it <container-name> <command>`, for example `docker exec -it snapraid snapraid diff`.

Note that by default snapraid-runner is set to run via cron at 00.30 daily. Tips and tricks on configuration snapraid-runner can be found on our [forums](https://forum.linuxserver.io/index.php?threads/snapraid-runner-script-email-issue.97).
