#!/usr/bin/env bash
# drives.sh - v3.8.1 generalized drive inventory tool (robust output + safer filtering + typo UX fix)

set -euo pipefail

# =========================================================
# CONFIG
# =========================================================

readonly LSBLK_COLUMNS="NAME,KNAME,PATH,TYPE,SIZE,MODEL,SERIAL,VENDOR,TRAN,FSTYPE,MOUNTPOINT"

# =========================================================
# GLOBAL STATE
# =========================================================

GLOBAL_TRANSPORT=""
GLOBAL_HUMAN="0"
ARGS=()

# =========================================================
# HELP
# =========================================================

print_help() {
  cat <<'EOF'
Usage:
  drives.sh [global options] <command>

Global options:
  --human                 human readable sizes
  --transport TYPE        filter by usb|sata|nvme
  -h, --help              show this help

Commands:
  list        show drives (default)
  json        raw lsblk json
  zpool       zpool device list
  unused      drives not in zpool
  byid        /dev/disk/by-id view
  stable      stable lsblk view

Examples:
  drives.sh list --human
  drives.sh --human list
  drives.sh list --transport usb
EOF
}

# =========================================================
# ARG PARSER
# =========================================================

parse_args() {
  ARGS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        print_help
        exit 0
        ;;
      --human)
        GLOBAL_HUMAN="1"
        shift
        ;;
      --transport)
        GLOBAL_TRANSPORT="$2"
        shift 2
        ;;
      *)
        ARGS+=("$1")
        shift
        ;;
    esac
  done

  [[ ${#ARGS[@]} -eq 0 ]] && ARGS=("list")

  # UX FIX: detect flag-like garbage commands
  if [[ "${ARGS[0]}" == --* ]]; then
    echo "Invalid command: ${ARGS[0]}"
    echo "Run: drives.sh --help"
    exit 1
  fi
}

# =========================================================
# DATA COLLECTION
# =========================================================

collect_lsblk_json() {
  lsblk --json --bytes -o "$LSBLK_COLUMNS"
}

collect_zpool_devices_json() {
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
# TRANSFORMS
# =========================================================

jq_disks_only() {
  # SAFER: include all common block disk families
  jq '
    .blockdevices[]
    | select(
        .type == "disk"
        and (.name | test("^(sd|nvme|vd|xvd|hd|mmcblk)") )
      )
  '
}

jq_filter_transport() {
  jq --arg t "$GLOBAL_TRANSPORT" 'select(.tran == $t)'
}

jq_enrich_zpool() {
  local zpool_json="$1"
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
      (.in_zpool // false),
      .path
    ] | @tsv
  '
}

# =========================================================
# OUTPUT
# =========================================================

render_table() {
  column -t -s $'\t'
}

humanize_sizes() {
  awk '
    function human(x) {
      split("B KB MB GB TB PB", u)
      i=1
      while (x >= 1024 && i < 6) { x/=1024; i++ }
      return sprintf("%.1f%s", x, u[i])
    }
    {
      $3 = human($3)
      print
    }
  '
}

print_header() {
  echo -e "NAME\tTRAN\tSIZE\tMODEL\tSERIAL\tZPOOL\tPATH" | column -t -s $'\t'
  printf '%*s\n' 100 '' | tr ' ' '-'
}

# =========================================================
# COMMANDS
# =========================================================

cmd_list() {
  local data zpool_json

  data="$(collect_lsblk_json)"
  zpool_json="$(collect_zpool_devices_json)"

  print_header

  echo "$data" \
    | jq_disks_only \
    | jq_enrich_zpool "$zpool_json" \
    | { [[ -n "$GLOBAL_TRANSPORT" ]] && jq_filter_transport || cat; } \
    | jq_to_table \
    | { [[ "$GLOBAL_HUMAN" == "1" ]] && humanize_sizes || cat; } \
    | render_table

  # UX FIX: empty output guard
  if [[ "$GLOBAL_HUMAN" == "1" && -z "$data" ]]; then
    echo "No drives found (lsblk returned empty)."
  fi
}

cmd_json() { collect_lsblk_json | jq .; }
cmd_zpool() { collect_zpool_devices_json | jq .; }

cmd_unused() {
  local data zpool_json

  data="$(collect_lsblk_json)"
  zpool_json="$(collect_zpool_devices_json)"

  print_header

  echo "$data" \
    | jq_disks_only \
    | jq_enrich_zpool "$zpool_json" \
    | jq 'select(.in_zpool == false)' \
    | jq_to_table \
    | render_table
}

cmd_byid() {
  ls -l /dev/disk/by-id/ 2>/dev/null | awk '{print $9 " -> " $11}' | sort
}

cmd_stable() {
  lsblk -o NAME,MODEL,SERIAL,TRAN,PATH --nodeps
}

# =========================================================
# MAIN
# =========================================================

main() {
  parse_args "$@"

  case "${ARGS[0]}" in
    list) cmd_list ;;
    json) cmd_json ;;
    zpool) cmd_zpool ;;
    unused) cmd_unused ;;
    byid) cmd_byid ;;
    stable) cmd_stable ;;
    *)
      echo "Unknown command: ${ARGS[0]}"
      echo "Run --help"
      exit 1
      ;;
  esac
}

main "$@"

