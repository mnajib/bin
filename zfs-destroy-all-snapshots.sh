#!/usr/bin/env bash

#
# !!! WARNING !!!
#
# This script will destroy (delete) all snapshots!
#

#for snap in $(zfs list -t snapshot -o name -H -r tank/home | grep "zfs-auto-snap_frequent-2023-11-02-11h"); do
#for snap in $(zfs list -t snapshot -o name -H -r tank/home ); do
for snap in $(zfs list -t snapshot -o name -H); do
  echo "zfs destroy $snap"
  sudo zfs destroy "$snap"
done

