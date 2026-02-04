#!/usr/bin/env bash
#~/bin/drives-list.sh

set -euo pipefail

# ----------------------------
# Helpers (mostly pure)
# ----------------------------

section() {
  echo ""
  echo "$1"
  echo "-------------------------------------------------------------------------"
}

list_ata_by_id() {
  ls -1 /dev/disk/by-id/ata-* | grep -v -- -part | sort
}

list_zfs_by_id() {
  zpool status -P \
    | grep '/dev/disk/by-id' \
    | awk '{print $1}' \
    | sed 's/-part[0-9]\+$//' \
    | sort -u
}

byid_to_sdx() {
  local byid="$1"
  basename "$(readlink -f "$byid")"
}

list_ata_byid_map_to_sdx() {
  ls -l /dev/disk/by-id/ata-* \
    | grep -v -- -part \
    | awk '{print $11 " " $9}' \
    | sed 's#\.\./\.\./##' \
    | awk '{print $2 " -> " $1}' \
    | sort
}

# list drives NOT in zpool
list_unused_by_id() {
  comm -23 \
    <(list_ata_by_id) \
    <(list_zfs_by_id)
}

# list drives in zpool
list_drives_in_zpool_by_id() {
  comm -12 \
    <(list_ata_by_id) \
    <(list_zfs_by_id)
}

list_drives_not_in_zpool_map_to_sdx() {
  while read -r byid; do
    #printf "%s -> %s\n" "$byid" "$(byid_to_sdx "$byid")"
    printf "%s -> %s\n" "$(byid_to_sdx "$byid")" "$byid"
  done < <(list_unused_by_id)
}

list_drives_in_zpool_map_to_sdx() {
  while read -r byid; do
    #printf "%s -> %s\n" "$byid" "$(byid_to_sdx "$byid")"
    printf "%s -> %s\n" "$(byid_to_sdx "$byid")" "$byid"
  done < <(list_drives_in_zpool_by_id)
}

# ----------------------------
# Output sections (impure)
# ----------------------------

section "Drives by connection"
lsscsi -g

section "Drives by-uuid"
ls -l /dev/disk/by-uuid/* \
  | grep -v -- -part \
  | awk '{print $11 " -> " $9}' \
  | sort

section "ATA Drives by-id"
ls -l /dev/disk/by-id/ata-* \
  | grep -v -- -part \
  | awk '{print $11 " -> " $9}' \
  | sort

section "ATA Drives in zpool"
#list_zfs_by_id
list_drives_in_zpool_map_to_sdx | sort

section "ATA Drives NOT in zpool"
#while read -r byid; do
#  printf "%s -> %s\n" "$byid" "$(byid_to_sdx "$byid")"
#done < <(list_unused_by_id)
list_drives_not_in_zpool_map_to_sdx | sort
