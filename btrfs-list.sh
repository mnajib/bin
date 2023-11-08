#!/usr/bin/env bash

MOUNT_POINT="$1"

# List devices associated with the Btrfs file system
#DEVICES=$(btrfs filesystem show "$MOUNT_POINT" | grep "devid" | awk '{print $2}' | sort -u)

# Loop through devices and display details
#for DEV_ID in $DEVICES; do
#    echo "Device ID: $DEV_ID"
#    btrfs device stats "$MOUNT_POINT" -d "$DEV_ID"
#done

btrfs device stats -T "$MOUNT_POINT"
