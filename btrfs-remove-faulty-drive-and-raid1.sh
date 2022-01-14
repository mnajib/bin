#!/usr/bin/env bash

# Removing the faulty disk & RAID1
# I did not have a spare drive available (yet), but I needed to remove the faulty drive from my RAID1. RAID1 cannot run with just a single disk, so I also needed to remove RAID1 entirely.
#
# First you should shut down the server and physically disconnect/remove the bad disk. Boot the server, which will take some time as it will try (and fail) to mount the existing /mnt/raid because the RAID1 is missing a drive.
#
# Manually mount the remaining drive in “degraded” mode.
# You will probably have to choose a new temporary path to mount it, as I think fstab confuses things when mounting to its original path (I wasn’t able to).
# Also note that you can ONLY mount your degraded RAID --> !!! ONCE !!! <-- with read/write capabilities, and any time you mount it degraded after that will mount it read-only.

# mount degraded to temporary location not defined in fstab
mkdir /mnt/raid-tmp
mount -o rw,degraded /dev/sde1 /mnt/raid-tmp

# convert to single (remove raid) - several hours
btrfs balance start -dconvert=single -mconvert=single /mnt/raid-tmp -f

# remove the faulty drive from the pool
btrfs device delete missing /mnt/raid-tmp

# At this point you should be able to umount /mnt/raid-tmp, and mount the single drive again to /mnt/raid as you previously did (you will need to set the new UUID /etc/fstab).
#
# When I get my drive replacement I’ll go about adding it again to the pool and converting back to RAID1.
