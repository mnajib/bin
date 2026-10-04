#!/usr/bin/env bash
# smart-link-report.sh (v3) -- compare link-health counters across SATA disks
#
# usage:  sudo ./smart-link-report.sh [disk-path ...]
#         (no args = every whole disk under /dev/disk/by-id/ata-*)
#
# output sections:
#   1. TABLE       full numbers, incl. rates per 1000 power-on hours
#   2. CHARTS      ASCII bar charts, worst disk first
#   3. VERDICT     OK / WATCH / SUSPECT / NO-DATA per disk, with reason
#   4. KESIMPULAN  counts and suggested action
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

# ---------------------------------------------------------------
# CONSTANTS (single source of truth -- edit here only)
# ---------------------------------------------------------------
readonly BAR_WIDTH=40          # width of the longest bar, in characters
readonly RST_KH_WARN=5         # mid-cmd resets per 1000 h: >= this -> WATCH
readonly RST_KH_BAD=20         # mid-cmd resets per 1000 h: >= this -> SUSPECT
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

# pure_title :: Text -> Text
pure_title() { printf '\n== %s ==\n' "$1"; }

# pure_record :: Name -> SmartctlText -> Record
# Record = TAB-separated: name poh cmd_tmo rst_mid hw_rst asr comreset crc
pure_record() {
  local name="$1" txt
  txt=$(cat)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$name" \
    "$(pure_attr_raw Power_On_Hours <<<"$txt" | pure_first_num | pure_or_dash)" \
    "$(pure_attr_raw Command_Timeout <<<"$txt" | pure_squash | pure_or_dash)" \
    "$(pure_devstat 'Resets Between Cmd Acceptance and Completion' <<<"$txt" | pure_or_dash)" \
    "$(pure_devstat 'Number of Hardware Resets' <<<"$txt" | pure_or_dash)" \
    "$(pure_devstat 'Number of ASR Events' <<<"$txt" | pure_or_dash)" \
    "$(pure_phy 'COMRESET' <<<"$txt" | pure_or_dash)" \
    "$(pure_devstat 'Number of Interface CRC Errors' <<<"$txt" | pure_or_dash)"
}

# pure_table :: Records -> Rows
pure_table() {
  awk -F'\t' -v fmt="$ROW_FMT" '
    function num(x) { return x ~ /^[0-9]+$/ }
    function rate(c, h) { return (num(c) && num(h) && h > 0) ? sprintf("%.1f", c * 1000 / h) : "-" }
    NF { printf fmt, $1, $2, $3, $4, rate($4, $2), $5, rate($5, $2), $6, $7, $8 }'
}

# pure_metric :: Kind -> Records -> Pairs      ("value<TAB>name" per disk)
# Kind = rstkh | rst | tmo
pure_metric() {
  awk -F'\t' -v k="$1" '
    function num(x) { return x ~ /^[0-9]+$/ }
    function last(s,   n, a) { n = split(s, a, "/"); return a[n] }
    NF {
      v = "-"
      if (k == "rstkh" && num($4) && num($2) && $2 > 0) v = $4 * 1000 / $2
      if (k == "rst"   && num($4))                      v = $4
      if (k == "tmo"   && num(last($3)))                v = last($3)
      if (v != "-") printf "%.1f\t%s\n", v, $1
    }'
}

# pure_verdict :: Records -> Verdicts          ("name STATUS reason" per disk)
pure_verdict() {
  awk -F'\t' -v warn="$RST_KH_WARN" -v bad="$RST_KH_BAD" '
    function num(x) { return x ~ /^[0-9]+$/ }
    NF {
      if (!num($4) || !num($2) || $2 == 0) {
        s = "NO-DATA"; why = "no Device Statistics reported"
      } else {
        r = $4 * 1000 / $2
        if      (r >= bad)  { s = "SUSPECT"; why = sprintf("%.1f mid-cmd resets/1000h (limit %s)", r, bad) }
        else if (r >= warn) { s = "WATCH";   why = sprintf("%.1f mid-cmd resets/1000h (limit %s)", r, warn) }
        else                { s = "OK";      why = sprintf("%.1f mid-cmd resets/1000h", r) }
      }
      if (num($8) && $8 > 0) why = why "; CRC errors=" $8 " (cable?)"
      printf "%-28s %-8s %s\n", $1, s, why
    }'
}

# pure_marks :: Verdicts -> Text               ("name=STATUS;name=STATUS;...")
pure_marks() { awk 'NF { printf "%s=%s;", $1, $2 }'; }

# pure_bars :: Title -> Marks -> Pairs -> Chart
pure_bars() {
  local title="$1" marks="$2"
  sort -t$'\t' -k1,1 -rn | awk -F'\t' -v t="$title" -v w="$BAR_WIDTH" -v marks="$marks" '
    BEGIN {
      np = split(marks, ps, ";")
      for (i = 1; i <= np; i++) { split(ps[i], kv, "="); st[kv[1]] = kv[2] }
    }
    { v[NR] = $1; n[NR] = $2 }
    END {
      print t
      max = v[1]
      fmt = "%-28s |%-" w "s %s%s\n"
      for (i = 1; i <= NR; i++) {
        len = (max > 0) ? int(v[i] / max * w + 0.5) : 0
        if (v[i] > 0 && len == 0) len = 1
        bar = ""
        for (j = 0; j < len; j++) bar = bar "#"
        tag = (st[n[i]] == "SUSPECT" || st[n[i]] == "WATCH") ? "  <-- " st[n[i]] : ""
        printf fmt, n[i], bar, v[i], tag
      }
    }'
}

# pure_conclusion :: Verdicts -> Text          (the KESIMPULAN section)
pure_conclusion() {
  awk '
    NF { total++; count[$2]++; names[$2] = names[$2] " " $1 }
    END {
      printf "Disks checked : %d  (OK %d, WATCH %d, SUSPECT %d, NO-DATA %d)\n",
             total, count["OK"], count["WATCH"], count["SUSPECT"], count["NO-DATA"]
      if (count["SUSPECT"])
        printf "SUSPECT       :%s\n  -> stalls far above peers; do not rely on it as a full pool member\n", names["SUSPECT"]
      else
        print "SUSPECT       : none above threshold"
      if (count["WATCH"])
        printf "WATCH         :%s\n  -> mildly elevated; re-run weekly, only the growth matters\n", names["WATCH"]
      if (count["NO-DATA"])
        printf "NO-DATA       :%s\n  -> cannot be judged by this script\n", names["NO-DATA"]
    }'
}

# pure_report :: Records -> Report
pure_report() {
  local recs verdicts marks
  recs=$(cat)
  verdicts=$(pure_verdict <<<"$recs")
  marks=$(pure_marks <<<"$verdicts")

  pure_title "1. TABLE (full numbers)"
  pure_header
  pure_table <<<"$recs"

  pure_title "2. CHARTS (worst disk first)"
  pure_metric rstkh <<<"$recs" | pure_bars "RST/kh (mid-command resets per 1000 h) -- main signal" "$marks"
  printf '\n'
  pure_metric rst   <<<"$recs" | pure_bars "RST_MID (mid-command resets, lifetime)" "$marks"
  printf '\n'
  pure_metric tmo   <<<"$recs" | pure_bars "CMD_TMO (command timeouts, last counter)" "$marks"

  pure_title "3. VERDICT (WATCH >= ${RST_KH_WARN}/kh, SUSPECT >= ${RST_KH_BAD}/kh)"
  printf '%-28s %-8s %s\n' DISK STATUS WHY
  printf '%s\n' "$verdicts"

  pure_title "4. KESIMPULAN / CONCLUSION"
  pure_conclusion <<<"$verdicts"
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

# io_record_one :: Path -> IO Record
io_record_one() {
  io_probe "$1" | pure_record "$(basename "$1" | pure_short_name)"
}

# io_disks_from_args :: [Path] -> IO [Path]
io_disks_from_args() {
  if [[ $# -gt 0 ]]; then printf '%s\n' "$@"; else io_list_disks; fi
}

# io_main :: [Path] -> IO ()
io_main() {
  [[ $EUID -eq 0 ]] || { echo "run with sudo: smartctl needs root" >&2; return 1; }
  io_disks_from_args "$@" | while read -r d; do io_record_one "$d"; done | pure_report
}

io_main "$@"
