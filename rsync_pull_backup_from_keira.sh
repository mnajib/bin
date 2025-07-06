#!/usr/bin/env bash

# Configuration
REMOTE_USER="julia"                  # Remote user on keira
REMOTE_HOST="keira"                 # Remote hostname/IP
BTRFS_SOURCE="/path/to/data"        # Btrfs subvolume to back up on keira
SNAPSHOT_DIR="/path/to/snapshots"   # Snapshot directory on keira
MOUNT_DIR="/mnt/backup_snapshot"    # Mount point for snapshot on keira
ZFS_DEST="/zfs/path/data"           # Destination path on customdesktop's ZFS

#SRC='julia@keira:/home/julia/'
#DES='/mnt/data/julia'

# Create snapshot on keira
SNAPSHOT_NAME="@backup_$(date +%Y%m%d)"
ssh "$REMOTE_USER@$REMOTE_HOST" \
  "sudo btrfs subvolume snapshot -r $BTRFS_SOURCE $SNAPSHOT_DIR/$SNAPSHOT_NAME"

# Mount snapshot on keira
ssh "$REMOTE_USER@$REMOTE_HOST" \
  "sudo mkdir -p $MOUNT_DIR && \
   sudo mount -o subvol=$SNAPSHOT_NAME $(df $BTRFS_SOURCE | awk 'NR==2 {print $1}') $MOUNT_DIR"

# Rsync from keira to customdesktop (pull)
#rsync -aAXv --delete "$REMOTE_USER@$REMOTE_HOST:$MOUNT_DIR/" "$ZFS_DEST/"
rsync -aAXv --delete "$REMOTE_USER@$REMOTE_HOST:$MOUNT_DIR/" "$ZFS_DEST/"
#rsync -vazPAX --progress --exclude=.cache --exclude=.snapshots --delete $SRC $DES

# Unmount snapshot on keira
ssh "$REMOTE_USER@$REMOTE_HOST" "sudo umount $MOUNT_DIR"

# Create ZFS snapshot on customdesktop
sudo zfs snapshot pool/backup/data@$(date +%Y%m%d)

echo "Pull backup completed."
