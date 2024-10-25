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
DEVICES=()
DEVICES=$(sudo btrfs filesystem show | grep "devid" | awk '{print $8}')
readonly DEVICES # make the variable readonly
#DEVICES=$(df -hT | grep 'btrfs' | awk '{print $1}' | sort -n | uniq)
#declare -A MPOINT # Declare an array
MPOINT=()
for DEVICE in $DEVICES; do
    #MPOINT[$DEVICE]=$(df -hT | grep 'btrfs' | awk '{print $1 " " $7}' | grep $DEVICE | awk '{print $2}' | uniq | head -1)
    MPOINT+=$(df -hT | grep 'btrfs' | awk '{print $1 " " $7}' | grep $DEVICE | awk '{print $2}' | uniq | head -1)
done


# Show a list of partition/disk (uuid), match with device name
# uuid:xxx ---> /dev/mapper/vg1-lvroot1
showAllBtrfsFilesystems() {
    echo
    echo "---------------------------------------"
    echo " btrfs filesystem show"
    echo "---------------------------------------"
    echo
    sudo btrfs filesystem show
}
showAllBtrfsFilesystems

showDeviceStatistic() {
  local devices="$1"
  for device in $devices; do
      echo
      echo "---------------------------------------"
      echo " btrfs device stats $device"
      echo "---------------------------------------"
      echo
      btrfs device stats $device
  done
}
showDeviceStatistic "$DEVICES"

showMounted() {
  local devices="$1"
  for device in $devices; do
    echo
    echo "---------------------------------------"
    echo " df -hT | grep $device"
    echo "---------------------------------------"
    echo
    df -hT | grep 'btrfs' | awk '{print $1 " " $7}' | uniq | grep "$device" | awk '{print "  " $2}'
    #mount_point=$(df -hT | grep 'btrfs' | awk '{print $1 " " $7}' | uniq | grep $device | awk '{print "  " $2}')
    #printf "%s --> %s" "$device" "$mount_point"
  done
}
showMounted "$DEVICES"

showFsUsageAndAlloc() {
  #local DEVICE=$1
  #local MOUNT_POINT=$2
  local $devices=$1

  for device in $devices; do
    # Display file system usage and allocation info
    echo
    echo '/---------------------------------------\'
    echo ' File System Usage and Allocation:       '
    echo " DEVICE=${device}"
    echo " MOUNT_POINT=${mount_point}"
    echo " btrfs filesystem df $mount_point"
    echo '\---------------------------------------/'
    echo
    btrfs filesystem df "$mount_point"
  done
}
#showFsUsageAndAlloc $DEVICES $MOUNT_POINT
#showFsUsageAndAlloc $DEVICES

getMountpointOfDevice() {
  local device="$1"
  local mount_point=$(df -hT | grep 'btrfs' | awk '{print $1 " " $7}' | uniq | grep $device | awk '{print "  " $2}' | head -1 )
  echo "$mount_point"
}
#getMountpointOfDevice $DEVICE

getMountpointOfDevices() {
  local devices="$1"
  for device in $devices; do
    echo
    echo "---------------------------------------"
    echo " df -hT | grep $device"
    echo "---------------------------------------"
    echo
    df -hT | grep 'btrfs' | awk '{print $1 " " $7}' | uniq | grep "$device" | awk '{print "  " $2}'
    #mount_point=$(df -hT | grep 'btrfs' | awk '{print $1 " " $7}' | uniq | grep $device | awk '{print "  " $2}')
    #printf "%s --> %s" "$device" "$mount_point"
  done
}
#getMountPoint $DEVICES

test() {
    echo
    echo '/---------------------------------------\'
    #echo " File System Usage:"
    echo " DEVICE=${DEVICE}"
    echo " MOUNT_POINT=${MOUNT_POINT}"
    echo " btrfs filesystem usage $MOUNT_POINT"
    echo '\---------------------------------------/'
    echo
    btrfs filesystem usage "$MOUNT_POINT"

    echo
    echo '/---------------------------------------\'
    echo " DEVICE=${DEVICE}"
    echo " MOUNT_POINT=${MOUNT_POINT}"
    echo " btrfs device usage -h $MOUNT_POINT"
    echo '\---------------------------------------/'
    echo
    btrfs device usage -h "$MOUNT_POINT"

    # Display scrub status
    echo
    echo '/---------------------------------------\'
    echo " Scrub Status:"
    echo " DEVICE=${DEVICE}"
    echo " MOUNT_POINT=${MOUNT_POINT}"
    echo '\---------------------------------------/'
    echo
    btrfs scrub status "$MOUNT_POINT"

    # Display balance status
    echo
    echo '/---------------------------------------\'
    echo " Balance Status:"
    echo " DEVICE=${DEVICE}"
    echo " MOUNT_POINT=${MOUNT_POINT}"
    echo '\---------------------------------------/'
    echo
    btrfs balance status "$MOUNT_POINT"

    # Display device stats
    echo
    echo '/---------------------------------------\'
    echo " Device Stats:"
    echo " DEVICE=${DEVICE}"
    echo " MOUNT_POINT=${MOUNT_POINT}"
    echo '\---------------------------------------/'
    echo
    btrfs device stats "$MOUNT_POINT"

} #End test()

