#!/usr/bin/env bash
# drives.sh - v3.3 generalized drive inventory tool (fix ZFS pipeline + jq robustness + UX stability)

set -euo pipefail

# =========================================================
# CONFIG
# =========================================================

readonly LSBLK_COLUMNS="NAME,KNAME,PATH,TYPE,SIZE,MODEL,SERIAL,VENDOR,TRAN,FSTYPE,MOUNTPOINT"

# =========================================================
# PURE DATA COLLECTION
# =========================================================

collect_lsblk_json() {
  lsblk --json --bytes -o "$LSBLK_COLUMNS"
}

collect_zpool_devices_json() {
  # Always output VALID JSON array of /dev paths
  local raw

  raw="$(zpool status -P 2>/dev/null || true)"

  if [[ -z "$raw" ]]; then
    echo '[]'
    return 0
  fi

  echo "$raw" \
    | awk '/^\/dev\// {print $1}' \
    | sed 's/-part[0-9]\+$//' \
    | sort -u \
    | jq -R -s 'split("\n") | map(select(length > 0))'
}

# =========================================================
# PURE TRANSFORMS (jq-based)
# =========================================================

jq_disks_only() {
  jq '.blockdevices[] | select(.type == "disk")'
}

jq_filter_transport() {
  local transport="$1"
  jq --arg t "$transport" 'select(.tran == $t)'
}

jq_enrich_zpool() {
  local zpool_json="$1"

  # ensure safe JSON array
  [[ -z "$zpool_json" ]] && zpool_json='[]'

  jq --argjson zp "$zpool_json" '
    . + {
      in_zpool: ((.path // "") as $p | ($zp | index($p)) != null)
    }
  '
}

jq_to_table() {
  jq -r '
    [
      .name,
      .tran,
      .size,
      .model,
      .serial,
      (.in_zpool // false)
    ] | @tsv
  '
}

# =========================================================
# IMPURE LAYER
# =========================================================

render_table() {
  column -t -s $'\t'
}

section() {
  echo
  echo "$1"
  printf '%*s\n' 72 '' | tr ' ' '-'
}

# =========================================================
# COMMANDS
# =========================================================

cmd_list() {
  local transport=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --transport)
        transport="$2"
        shift 2
        ;;
      --help)
        echo "Usage: drives list [--transport usb|sata|nvme]"
        exit 0
        ;;
      *)
        shift
        ;;
    esac
  done

  local data zpool_json

  data="$(collect_lsblk_json)"
  zpool_json="$(collect_zpool_devices_json)"

  echo "$data" \
    | jq_disks_only \
    | jq_enrich_zpool "$zpool_json" \
    | { [[ -n "$transport" ]] && jq_filter_transport "$transport" || cat; } \
    | jq_to_table \
    | render_table
}

cmd_json() {
  collect_lsblk_json | jq .
}

cmd_zpool() {
  collect_zpool_devices_json | jq .
}

cmd_unused() {
  local data zpool_json

  data="$(collect_lsblk_json)"
  zpool_json="$(collect_zpool_devices_json)"

  echo "$data" \
    | jq_disks_only \
    | jq_enrich_zpool "$zpool_json" \
    | jq 'select(.in_zpool == false)' \
    | jq_to_table \
    | render_table
}

cmd_byid() {
  ls -l /dev/disk/by-id/ 2>/dev/null \
    | awk '{print $9 " -> " $11}' \
    | sort
}

cmd_stable() {
  lsblk -o NAME,MODEL,SERIAL,TRAN,PATH --nodeps
}

# =========================================================
# MAIN
# =========================================================

main() {
  local cmd="list"

  if [[ $# -gt 0 ]]; then
    cmd="$1"
    shift
  fi

  case "$cmd" in
    list)
      cmd_list "$@"
      ;;
    json)
      cmd_json
      ;;
    zpool)
      cmd_zpool
      ;;
    unused)
      cmd_unused
      ;;
    byid)
      cmd_byid
      ;;
    stable)
      cmd_stable
      ;;
    *)
      echo "Unknown command: $cmd"
      echo "Available commands: list | json | zpool | unused | byid | stable"
      exit 1
      ;;
  esac
}

main "$@"

