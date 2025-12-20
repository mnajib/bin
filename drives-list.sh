#!/usr/bin/env bash

ls -l /dev/disk/by-id/ata-* | grep -v -- -part | awk '{print $11 " -> " $9}' | sort
echo ""
ls -l /dev/disk/by-uuid/* | grep -v -- -part | awk '{print $11 " -> " $9}' | sort
echo ""
lsscsi -g
