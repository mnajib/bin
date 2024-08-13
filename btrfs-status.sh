#!/usr/bin/env bash

# Path to your Btrfs mount point
#MOUNT_POINT="/home"
MOUNT_POINT="$1"

#echo "DEBUG: MOUNT_POINT = $MOUNT_POINT"

# Display file system usage and allocation info
echo
echo '/---------------------------------------\'
#echo ' File System Usage and Allocation:       '
echo " btrfs filesystem df $MOUNT_POINT"
echo '\---------------------------------------/'
echo
#btrfs filesystem df "$MOUNT_POINT"
sudo btrfs filesystem df "$MOUNT_POINT"

echo
echo '/---------------------------------------\'
#echo " File System Usage:"
echo " btrfs filesystem usage $MOUNT_POINT"
echo '\---------------------------------------/'
echo
#btrfs filesystem usage "$MOUNT_POINT"
sudo btrfs filesystem usage "$MOUNT_POINT"

echo
echo '/---------------------------------------\'
echo " btrfs device usage -h $MOUNT_POINT"
echo '\---------------------------------------/'
echo
#btrfs device usage -h "$MOUNT_POINT"
sudo btrfs device usage -h "$MOUNT_POINT"

# Display scrub status
echo
echo '/---------------------------------------\'
echo " Scrub Status:"
echo '\---------------------------------------/'
echo
#btrfs scrub status "$MOUNT_POINT"
sudo btrfs scrub status "$MOUNT_POINT"

# Display balance status
echo
echo '/---------------------------------------\'
echo " Balance Status:"
echo '\---------------------------------------/'
echo
#btrfs balance status "$MOUNT_POINT"
sudo btrfs balance status "$MOUNT_POINT"

# Display device stats
echo
echo '/---------------------------------------\'
echo " Device Stats:"
echo '\---------------------------------------/'
echo
#btrfs device stats "$MOUNT_POINT"
sudo btrfs device stats "$MOUNT_POINT"

