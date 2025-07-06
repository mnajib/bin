#!/usr/bin/env bash

# Configuration
REMOTE_USER="user"                  # Remote user on customdesktop
REMOTE_HOST="customdesktop"         # Remote hostname/IP
BTRFS_SOURCE="/path/to/data"        # Btrfs subvolume to back up on keira
SNAPSHOT_DIR="/path/to/snapshots"   # Snapshot directory on keira
MOUNT_DIR="/mnt/backup_snapshot"    # Mount point for snapshot on keira
ZFS_DEST="/zfs/path/data"           # Destination path on customdesktop's ZFS

# Create snapshot on keira
SNAPSHOT_NAME="@backup_$(date +%Y%m%d)"
sudo btrfs subvolume snapshot -r "$BTRFS_SOURCE" "$SNAPSHOT_DIR/$SNAPSHOT_NAME"

# Mount snapshot on keira
sudo mkdir -p "$MOUNT_DIR"
sudo mount -o subvol="$SNAPSHOT_NAME" "$(df "$BTRFS_SOURCE" | awk 'NR==2 {print $1}')" "$MOUNT_DIR"

# Rsync from keira to customdesktop (push)
rsync -aAXv --delete "$MOUNT_DIR/" "$REMOTE_USER@$REMOTE_HOST:$ZFS_DEST/"

# Unmount snapshot on keira
sudo umount "$MOUNT_DIR"

# Create ZFS snapshot on customdesktop (via SSH)
ssh "$REMOTE_USER@$REMOTE_HOST" "sudo zfs snapshot pool/backup/data@$(date +%Y%m%d)"

echo "Push backup completed."
