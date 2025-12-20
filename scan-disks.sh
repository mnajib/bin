#!/usr/bin/env bash

# Get all physical disks (excluding loop, ram, rom)
DISKS=$(lsblk -dno NAME,TYPE | grep disk | awk '{print $1}')

echo "{"
for DEV in $DISKS; do
    # Extract hardware properties from udev
    # We prioritize the ID_SERIAL for 'by-id' to match your naming convention
    ID_SERIAL=$(udevadm info --query=property --name="/dev/$DEV" | grep "^ID_SERIAL=" | cut -d= -f2)
    ID_BUS=$(udevadm info --query=property --name="/dev/$DEV" | grep "^ID_BUS=" | cut -d= -f2)
    ID_PATH=$(udevadm info --query=property --name="/dev/$DEV" | grep "^ID_PATH=" | cut -d= -f2)
    
    # Get the filesystem UUID or ZFS GUID if available
    ID_UUID=$(lsblk -no UUID "/dev/$DEV" | head -n1)

    echo "  drive_$DEV = {"
    
    if [ -n "$ID_SERIAL" ]; then
        echo "    by-id = \"$ID_BUS-$ID_SERIAL\";"
    fi

    if [ -n "$ID_PATH" ]; then
        echo "    by-path = \"$ID_PATH\";"
    fi

    if [ -n "$ID_UUID" ]; then
        echo "    by-uuid = \"$ID_UUID\";"
    fi

    echo "  };"
done
echo "}"
