#!/usr/bin/env bash

#
# Usage:
#   ~/bin/unhang-mounted-nfs.sh /mnt/nfsshare2
#

MOUNT_POINT=$1

if [ -z "$MOUNT_POINT" ]; then
    echo "Error: Please provide the mount point path."
    echo "Example: ./unhang.sh /mnt/nfs_share"
    exit 1
fi

# 1. Clear processes using the mount
# fuser -km: Kills all mounted processes holding the directory open.
echo "Killing processes on $MOUNT_POINT..."
sudo fuser -km "$MOUNT_POINT"

# 2. Lazy force unmount
# umount -f: Force: Tells the kernel to stop waiting for the server.
# umount -l: Lazy: Unstacks the mount immediately so you can use your terminal.
echo "Detaching $MOUNT_POINT..."
sudo umount -fl "$MOUNT_POINT"

echo "Done."
