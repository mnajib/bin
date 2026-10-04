#!/usr/bin/env bash
# smart-link-report.sh -- compare link-health counters across SATA disks
#
# usage:  sudo ./smart-link-report.sh [disk-path ...]
#         (no args = every whole disk under /dev/disk/by-id/ata-*)
#
# columns:
#   CMD_TMO  = SMART attr 188 Command_Timeout (raw, spaces become '/')
#   RST_MID  = Resets Between Cmd Acceptance and Completion (lifetime)
#   HW_RST   = Number of Hardware Resets (lifetime)
#   ASR      = Number of ASR Events (lifetime)
#   COMRESET = SATA Phy COMRESET count (since last drive power-on)
#   CRC      = Number of Interface CRC Errors (lifetime)
set -euo pipefail

# single source of truth for the table layout (header and rows share it)
readonly ROW_FMT='%-28s %-9s %-8s %-8s %-6s %-9s %-5s\n'

# ---------------------------------------------------------------
# PURE FUNCTIONS (stdin -> stdout, no side effects)
# ---------------------------------------------------------------

# pure_attr_raw :: AttrName -> Text -> Text
# smartctl -x attribute row: $1=id $2=name $3=flags $4..$7=value..fail, rest=raw
pure_attr_raw() {
  awk -v n="$1" '$2 == n { $1=$2=$3=$4=$5=$6=$7=""; sub(/^ +/, ""); print; exit }'
}

# pure_devstat :: Description -> Text -> Text
# Device Statistics row: $1=page $2=offset $3=size $4=value ...
pure_devstat() {
  awk -v d="$1" 'index($0, d) && $1 ~ /^0x0/ { print $4; exit }'
}

# pure_phy :: Description -> Text -> Text
# SATA Phy Event Counters row: $1=id $2=size $3=value ...
pure_phy() {
  awk -v d="$1" 'index($0, d) && $1 ~ /^0x0/ { print $3; exit }'
}

# pure_squash :: Text -> Text      ("0 0 490" -> "0/0/490")
pure_squash() { tr ' ' '/'; }

# pure_or_dash :: Text -> Text     (empty input -> "-")
pure_or_dash() { local x; x=$(cat); printf '%s' "${x:--}"; }

# pure_short_name :: Text -> Text  (drop "ata-", keep last 28 chars)
pure_short_name() { sed 's/^ata-//' | rev | cut -c1-28 | rev; }

# pure_header :: Text
pure_header() {
  # shellcheck disable=SC2059
  printf "$ROW_FMT" DISK CMD_TMO RST_MID HW_RST ASR COMRESET CRC
}

# pure_row :: Name -> SmartctlText -> Row
pure_row() {
  local name="$1" txt
  txt=$(cat)
  # shellcheck disable=SC2059
  printf "$ROW_FMT" \
    "$name" \
    "$(pure_attr_raw Command_Timeout <<<"$txt" | pure_squash | pure_or_dash)" \
    "$(pure_devstat 'Resets Between Cmd Acceptance and Completion' <<<"$txt" | pure_or_dash)" \
    "$(pure_devstat 'Number of Hardware Resets' <<<"$txt" | pure_or_dash)" \
    "$(pure_devstat 'Number of ASR Events' <<<"$txt" | pure_or_dash)" \
    "$(pure_phy 'COMRESET' <<<"$txt" | pure_or_dash)" \
    "$(pure_devstat 'Number of Interface CRC Errors' <<<"$txt" | pure_or_dash)"
}

# ---------------------------------------------------------------
# IO FUNCTIONS (touch the system)
# ---------------------------------------------------------------

# io_list_disks :: IO [Path]   (whole disks only, no -partN)
io_list_disks() {
  local p
  for p in /dev/disk/by-id/ata-*; do
    [[ "$p" == *-part* ]] || printf '%s\n' "$p"
  done
}

# io_probe :: Path -> IO Text  (smartctl exit code is a bitmask; ignore it)
io_probe() { smartctl -x "$1" 2>/dev/null || true; }

# io_report_one :: Path -> IO Row
io_report_one() {
  io_probe "$1" | pure_row "$(basename "$1" | pure_short_name)"
}

# io_disks_from_args :: [Path] -> IO [Path]
io_disks_from_args() {
  if [[ $# -gt 0 ]]; then printf '%s\n' "$@"; else io_list_disks; fi
}

# io_main :: [Path] -> IO ()
io_main() {
  [[ $EUID -eq 0 ]] || { echo "run with sudo: smartctl needs root" >&2; return 1; }
  pure_header
  io_disks_from_args "$@" | while read -r d; do io_report_one "$d"; done
}

io_main "$@"
