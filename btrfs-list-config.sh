#!/usr/bin/env bash

# List all Btrfs subvolumes
#SUBVOLUMES=$(btrfs subvolume list -a)

# Extract subvolume paths and IDs
#SUBVOLUME_PATHS=$(echo "$SUBVOLUMES" | awk '{print $9}')
#SUBVOLUME_IDS=$(echo "$SUBVOLUMES" | awk '{print $2}')

# Iterate through subvolumes and find the device associated with each
#for SUBVOLUME_PATH in $SUBVOLUME_PATHS; do
#  SUBVOLUME_ID=$(echo "$SUBVOLUME_IDS" | head -n 1)
#  DEVICE=$(btrfs subvolume find-new "$SUBVOLUME_PATH" "$SUBVOLUME_ID" | grep "devid" | awk '{print $2}')
#  echo "Subvolume Path: $SUBVOLUME_PATH"
#  echo "Device ID: $DEVICE"
#  echo
#done

# Show a list of partition/disk (uuid), match with device name
# uuid:xxx ---> /dev/mapper/vg1-lvroot1
    echo
    echo "---------------------------------------"
    echo " btrfs filesystem show"
    echo "---------------------------------------"
    echo
btrfs filesystem show

DEVICES=$(btrfs filesystem show | grep "devid" | awk '{print $8}')
#DEVICES=$(df -hT | grep 'btrfs' | awk '{print $1}' | sort -n | uniq)

for DEVICE in $DEVICES; do
    echo
    echo "---------------------------------------"
    echo " btrfs device stats $DEVICE"
    echo "---------------------------------------"
    echo
    btrfs device stats $DEVICE
done

for DEVICE in $DEVICES; do
    echo
    echo "---------------------------------------"
    echo " df -hT | grep $DEVICE"
    echo "---------------------------------------"
    echo
    df -hT | grep 'btrfs' | awk '{print $1 " " $7}' | uniq | grep $DEVICE | awk '{print "  " $2}'
done

for DEVICE in $DEVICES; do
    #echo
    #echo "---------------------------------------"
    #echo " df -hT | grep $DEVICE | awk ''"
    #echo "---------------------------------------"
    #echo
    THEPATH=$(df -hT | grep 'btrfs' | awk '{print $1 " " $7}' | uniq | grep $DEVICE | awk '{print $2}' | head -1)
    #echo "$THEPATH"
    #/home/julia/bin/btrfs-status.sh "$THEPATH"

    #MOUNT_POINT="$1"
    MOUNT_POINT="$THEPATH"
    
    # Display file system usage and allocation info
    echo
    echo '/---------------------------------------\'
    #echo ' File System Usage and Allocation:       '
    echo " btrfs filesystem df $MOUNT_POINT"
    echo '\---------------------------------------/'
    echo
    btrfs filesystem df "$MOUNT_POINT"
    
    echo
    echo '/---------------------------------------\'
    #echo " File System Usage:"
    echo " btrfs filesystem usage $MOUNT_POINT"
    echo '\---------------------------------------/'
    echo
    btrfs filesystem usage "$MOUNT_POINT"
    
    echo
    echo '/---------------------------------------\'
    echo " btrfs device usage -h $MOUNT_POINT"
    echo '\---------------------------------------/'
    echo
    btrfs device usage -h "$MOUNT_POINT"
    
    # Display scrub status
    echo
    echo '/---------------------------------------\'
    echo " Scrub Status:"
    echo '\---------------------------------------/'
    echo
    btrfs scrub status "$MOUNT_POINT"
    
    # Display balance status
    echo
    echo '/---------------------------------------\'
    echo " Balance Status:"
    echo '\---------------------------------------/'
    echo
    btrfs balance status "$MOUNT_POINT"
    
    # Display device stats
    echo
    echo '/---------------------------------------\'
    echo " Device Stats:"
    echo '\---------------------------------------/'
    echo
    btrfs device stats "$MOUNT_POINT"

done


