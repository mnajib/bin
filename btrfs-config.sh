#!/usr/bin/env bash
#
# Print btrfs config info
#

# Get the Btrfs mount point
#MOUNT_POINT="/path/to/mount/point"  # Replace with your actual mount point
MOUNT_POINT="$1"

# Get Btrfs file system details
BTRFS_INFO=$(btrfs filesystem show "$MOUNT_POINT")

# Get Btrfs file system properties
BTRFS_PROPERTIES=$(btrfs property list "$MOUNT_POINT")

# Get Btrfs device information
BTRFS_DEVICES=$(btrfs device stats "$MOUNT_POINT")

# Get Btrfs balance status
BTRFS_BALANCE_STATUS=$(btrfs balance status "$MOUNT_POINT")

# Display the gathered information
echo "Btrfs Configuration Information for $MOUNT_POINT:"
echo "-----------------------------------------"
echo "Btrfs File System Details:"
echo "$BTRFS_INFO"
echo
echo "Btrfs File System Properties:"
echo "$BTRFS_PROPERTIES"
echo
echo "Btrfs Device Information:"
echo "$BTRFS_DEVICES"
echo
echo "Btrfs Balance Status:"
echo "$BTRFS_BALANCE_STATUS"

