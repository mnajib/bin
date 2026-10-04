#!/usr/bin/env bash
# smart-link-report.sh (v2) -- compare link-health counters across SATA disks
#
# usage:  sudo ./smart-link-report.sh [disk-path ...]
#         (no args = every whole disk under /dev/disk/by-id/ata-*)
#
# columns:
#   POH      = SMART attr 9 Power_On_Hours
#   CMD_TMO  = SMART attr 188 Command_Timeout (raw, spaces become '/')
#   RST_MID  = Resets Between Cmd Acceptance and Completion (lifetime)
#   RST/kh   = RST_MID per 1000 power-on hours
#   HW_RST   = Number of Hardware Resets (lifetime)
#   HW/kh    = HW_RST per 1000 power-on hours
#   ASR      = Number of ASR Events (lifetime)
#   COMRESET = SATA Phy COMRESET count (since last drive power-on)
#   CRC      = Number of Interface CRC Errors (lifetime)
#
# '-' means the drive does not report that value (older drives often
# lack the Device Statistics log).
set -euo pipefail

# single source of truth for the table layout (header and rows share it)
readonly ROW_FMT='%-28s %-7s %-9s %-8s %-7s %-8s %-7s %-6s %-9s %-5s\n'

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

# pure_first_num :: Text -> Text   ("7751h+30m" -> "7751")
pure_first_num() { sed 's/[^0-9].*//'; }

# pure_rate :: Count -> Hours -> Text   (count per 1000 hours, or "-")
pure_rate() {
  awk -v c="$1" -v h="$2" 'BEGIN {
    if (c ~ /^[0-9]+$/ && h ~ /^[0-9]+$/ && h > 0) printf "%.1f", c * 1000 / h
    else printf "-"
  }'
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
  printf "$ROW_FMT" DISK POH CMD_TMO RST_MID RST/kh HW_RST HW/kh ASR COMRESET CRC
}

# pure_row :: Name -> SmartctlText -> Row
pure_row() {
  local name="$1" txt poh rst hw
  txt=$(cat)
  poh=$(pure_attr_raw Power_On_Hours <<<"$txt" | pure_first_num)
  rst=$(pure_devstat 'Resets Between Cmd Acceptance and Completion' <<<"$txt")
  hw=$(pure_devstat 'Number of Hardware Resets' <<<"$txt")
  # shellcheck disable=SC2059
  printf "$ROW_FMT" \
    "$name" \
    "$(pure_or_dash <<<"$poh")" \
    "$(pure_attr_raw Command_Timeout <<<"$txt" | pure_squash | pure_or_dash)" \
    "$(pure_or_dash <<<"$rst")" \
    "$(pure_rate "$rst" "$poh")" \
    "$(pure_or_dash <<<"$hw")" \
    "$(pure_rate "$hw" "$poh")" \
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
