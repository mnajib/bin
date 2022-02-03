#!/usr/bin/env bash

# Creating a RAID1 storage
# There are a lot of tutorials online for setting up hard drives & various RAID systems with btrfs, including the official documentation. I’m just documenting the method I used to net up my RAID1 for future reference, and to help anyone else along the way.
# For this example, I have two blank drive partitions (the same size) /dev/sde1 & /dev/sdf1 which I want to set up with RAID1, and mount to /mnt/raid.

# create the btrfs filesystems
mkfs.btrfs /dev/sde1
mkfs.btrfs /dev/sdf1

# mount the first drive
mount /dev/sde1 /mnt/raid

# add the second drive - resulting in combined storage capacity spanned across both drives
btrfs device add /dev/sdf1 /mnt/raid -f

# create RAID1 of data and metadata (important in case one drive fails)
# depending on your drive size, this can take several hours to complete
btrfs balance start -dconvert=raid1 -mconvert=raid1 /mnt/raid

# Set the mount point in your /etc/fstab with the UUID of your RAID which you can see in blkid --match-token TYPE=btrfs
UUID=<UUID>    /mnt/raid btrfs    defaults,autodefrag    0 2

# At this point /mnt/raid/ is a RAID1 using /dev/sde1 & /dev/sdb2. Any file you write or edit is automatically saved to both mirrored drives.
