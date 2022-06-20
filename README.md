# Snapraid in Docker  
This is container uses the latest alpine to compile snapraid from source and combines it with a modified snapraid-runner script for additional functionality.
These are the source repos for more info:  
https://github.com/amadvance/snapraid  
https://github.com/fightforlife/snapraid-runner  

## Usage
This container is configured using two files `snapraid.conf` and `snapraid-runner.conf`. These files neet to be mounted into the container at `/config` before the container starts.

### Docker Compose example
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
       - TZ=Europe/Berlin
       - PGID=1000
       - GUID=1000
       - CRON_SCHEDULE=0 3 * * *

volumes:
  config:
```

**Parameters**
* `-v /mnt` - The location of your data disks, a good convention is `/mnt/disk*` for your data drives
* `-v /config` - The location of the Snapraid and SnapRAID-runner configurations
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e CRON_SCHEDULE=0 3 * * *` here you can set the schedule when the snapraid runner is started. (see https://crontab.guru/)


### Detecting move operations
You'll probably notice when snapraid runs it gives a warning like `WARNING! UUID is unsupported for disks` and it may not detect moved files. Instead it seems them as copied and removed. In order to detect the file moves you can run with the following additional paramters.

* `--privileged` will share all your devices (ie `/dev/sdb`, `/dev/sdb1`, etc) with your container. Alternatively, you could probably use something like `--device /dev/sdb:/dev/sdb --device /dev/sdb1:/dev/sdb1`, but you'd need to do it for each drive you have setup.
* `--mount type=bind,source=/dev/disk,target=/dev/disk` mounts the disk listing into the container, so snapraid can run something like `ls /dev/disk/by-uuid` to get a list of all the disks by UUID

### User / Group Identifiers
The `PGID` and `PUID` values set the user / group you'd like your container to 'run as' to the host OS. This can be a user you've created or even root (not recommended).


## Setting up the application
SnapRAID has a comprehensive manual available [here](http://www.snapraid.it/). Any SnapRAID command can be executed from the host easily using `docker exec -it <container-name> <command>`, for example `docker exec -it snapraid snapraid diff`.
Tips and tricks on configuration snapraid-runner can be found on our [forums](https://forum.linuxserver.io/index.php?threads/snapraid-runner-script-email-issue.97).


## snapraid-runner.conf example
```
[snapraid]
; path to the snapraid executable (e.g. /bin/snapraid)
executable = /usr/bin/snapraid
; path to the snapraid config to be used
config = /config/snapraid.conf
; abort operation if there are more deletes than this, set to -1 to disable
deletethreshold = 200
; if you want touch to be ran each time
touch = true

[logging]
; logfile to write to, leave empty to disable
file = snapraid-runner.log
; maximum logfile size in KiB, leave empty for infinite
maxsize = 5000

[notification]
enabled = true
; when to send a notificariton on, comma-separated list of [success, error]
sendon = success,error
; set to false to get full programm output
short = true
; Python Apprise url.
url = discord://ID/Token

[scrub]
; set to true to run scrub after sync
enabled = true
; scrub plan - either a percentage or one of [bad, new, full]
plan = 12
; minimum block age (in days) for scrubbing. Only used with percentage plans
older-than = 10
```

## snapraid.conf example
```
# Example configuration for snapraid

# Defines the file to use as parity storage
# It must NOT be in a data disk
# Format: "parity FILE [,FILE] ..."
parity /mnt/HDD4/snapraid.parity

# Defines the files to use as additional parity storage.
# If specified, they enable the multiple failures protection
# from two to six level of parity.
# To enable, uncomment one parity file for each level of extra
# protection required. Start from 2-parity, and follow in order.
# It must NOT be in a data disk
# Format: "X-parity FILE [,FILE] ..."
#2-parity /mnt/diskq/snapraid.2-parity
#3-parity /mnt/diskr/snapraid.3-parity
#4-parity /mnt/disks/snapraid.4-parity
#5-parity /mnt/diskt/snapraid.5-parity
#6-parity /mnt/disku/snapraid.6-parity

# Defines the files to use as content list
# You can use multiple specification to store more copies
# You must have least one copy for each parity file plus one. Some more don't hurt
# They can be in the disks used for data, parity or boot,
# but each file must be in a different disk
# Format: "content FILE"
content /config/snapraid.content
content /mnt/HDD1/snapraid.content
content /mnt/HDD2/snapraid.content
content /mnt/HDD3/snapraid.content

# Defines the data disks to use
# The name and mount point association is relevant for parity, do not change it
# WARNING: Adding here your /home, /var or /tmp disks is NOT a good idea!
# SnapRAID is better suited for files that rarely changes!
# Format: "data DISK_NAME DISK_MOUNT_POINT"
data d1 /mnt/HDD1/
data d2 /mnt/HDD2/
data d3 /mnt/HDD3/

# Excludes hidden files and directories (uncomment to enable).
#nohidden

# Defines files and directories to exclude
# Remember that all the paths are relative at the mount points
# Format: "exclude FILE"
# Format: "exclude DIR/"
# Format: "exclude /PATH/FILE"
# Format: "exclude /PATH/DIR/"
exclude *.bak
exclude *.unrecoverable
exclude /tmp/
exclude /lost+found/
exclude .AppleDouble
exclude ._AppleDouble
exclude .DS_Store
exclude .Thumbs.db
exclude .fseventsd
exclude .Spotlight-V100
exclude .TemporaryItems
exclude .Trashes
exclude .AppleDB

# Defines the block size in kibi bytes (1024 bytes) (uncomment to enable).
# WARNING: Changing this value is for experts only!
# Default value is 256 -> 256 kibi bytes -> 262144 bytes
# Format: "blocksize SIZE_IN_KiB"
#blocksize 256

# Defines the hash size in bytes (uncomment to enable).
# WARNING: Changing this value is for experts only!
# Default value is 16 -> 128 bits
# Format: "hashsize SIZE_IN_BYTES"
#hashsize 16

# Automatically save the state when syncing after the specified amount
# of GB processed (uncomment to enable).
# This option is useful to avoid to restart from scratch long 'sync'
# commands interrupted by a machine crash.
# It also improves the recovering if a disk break during a 'sync'.
# Default value is 0, meaning disabled.
# Format: "autosave SIZE_IN_GB"
#autosave 500

# Defines the pooling directory where the virtual view of the disk
# array is created using the "pool" command (uncomment to enable).
# The files are not really copied here, but just linked using
# symbolic links.
# This directory must be outside the array.
# Format: "pool DIR"
#pool /pool

# Defines a custom smartctl command to obtain the SMART attributes
# for each disk. This may be required for RAID controllers and for
# some USB disk that cannot be autodetected.
# In the specified options, the "%s" string is replaced by the device name.
# Refers at the smartmontools documentation about the possible options:
# RAID -> https://www.smartmontools.org/wiki/Supported_RAID-Controllers
# USB -> https://www.smartmontools.org/wiki/Supported_USB-Devices
#smartctl d1 -d sat %s
#smartctl d2 -d usbjmicron %s
#smartctl parity -d areca,1/1 /dev/sg0
#smartctl 2-parity -d areca,2/1 /dev/sg0
```
