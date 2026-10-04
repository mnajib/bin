#!/usr/bin/env bash
# smart-link-report.sh (v4) -- compare link-health counters across SATA disks
#                              and relate them to the zpool layout
#
# usage:  sudo ./smart-link-report.sh [disk-path ...]
#         (no args = every whole disk under /dev/disk/by-id/ata-*)
#         pass /dev/disk/by-id/... paths, so names match zpool status
#
# output sections:
#   1. TABLE       full numbers, incl. rates per 1000 power-on hours
#   2. CHARTS      ASCII bar charts, worst disk first
#   3. VERDICT     OK / WATCH / SUSPECT / NO-DATA per disk, with its pool role
#   4. POOLS       per-pool summary from zpool status -v (members, spares)
#   5. KESIMPULAN  counts and suggested actions
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
#
# record format (TAB separated, one line per disk):
#   1 short-name  2 poh  3 cmd_tmo  4 rst_mid  5 hw_rst  6 asr
#   7 comreset    8 crc  9 full by-id name
set -euo pipefail

# ---------------------------------------------------------------
# CONSTANTS (single source of truth -- edit here only)
# ---------------------------------------------------------------
readonly BAR_WIDTH=40          # width of the longest bar, in characters
readonly RST_KH_WARN=5         # mid-cmd resets per 1000 h: >= this -> WATCH
readonly RST_KH_BAD=20         # mid-cmd resets per 1000 h: >= this -> SUSPECT
readonly SPARE_TARGET=2        # wanted number of HEALTHY free spares per pool
                               # (only checked for pools that have spares)
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

# pure_tag :: Tag -> Lines -> Lines     (prefix each non-empty line with "Tag<TAB>")
# lets two different record streams be merged into one awk input
pure_tag() { awk -v t="$1" 'NF { printf "%s\t%s\n", t, $0 }'; }

# pure_pick :: Tag -> Lines -> Lines    (keep lines tagged Tag, drop the tag)
# tags are one letter, so the payload starts at character 3
pure_pick() { awk -F'\t' -v t="$1" '$1 == t { print substr($0, 3) }'; }

# pure_record :: ById -> SmartctlText -> Record
pure_record() {
  local id="$1" txt short
  txt=$(cat)
  short=$(printf '%s\n' "$id" | pure_short_name)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$short" \
    "$(pure_attr_raw Power_On_Hours <<<"$txt" | pure_first_num | pure_or_dash)" \
    "$(pure_attr_raw Command_Timeout <<<"$txt" | pure_squash | pure_or_dash)" \
    "$(pure_devstat 'Resets Between Cmd Acceptance and Completion' <<<"$txt" | pure_or_dash)" \
    "$(pure_devstat 'Number of Hardware Resets' <<<"$txt" | pure_or_dash)" \
    "$(pure_devstat 'Number of ASR Events' <<<"$txt" | pure_or_dash)" \
    "$(pure_phy 'COMRESET' <<<"$txt" | pure_or_dash)" \
    "$(pure_devstat 'Number of Interface CRC Errors' <<<"$txt" | pure_or_dash)" \
    "$id"
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

# pure_verdict :: Records -> VerdictRecords
# VerdictRecord = TAB separated: by-id, short-name, STATUS, reason
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
      printf "%s\t%s\t%s\t%s\n", $9, $1, s, why
    }'
}

# pure_marks :: VerdictRecords -> Text         ("short=STATUS;short=STATUS;...")
pure_marks() { awk -F'\t' 'NF { printf "%s=%s;", $2, $3 }'; }

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

# pure_pool_roles :: ZpoolStatusText -> RoleRecords
# RoleRecord = TAB separated: by-id, pool, pool-state, role, device-state
# roles: member | replaced | standing-in | joining | spare | aux
#   replaced    = old disk inside spare-N / replacing-N
#   standing-in = spare currently covering a disk (inside spare-N)
#   joining     = new disk inside replacing-N
# a spare that is INUSE is skipped in the "spares" list (it already appears
# as standing-in), so every disk shows up once
pure_pool_roles() {
  awk '
    function is_vdev(s) { return s ~ /^(mirror|raidz[123]|draid[^ ]*)-[0-9]+$/ }
    { ind = match($0, /[^ ]/) - 1 }
    $1 == "pool:"   { pool = $2; inconf = 0; section = "data"; inpair = 0; gotstate = 0; pstate = "?"; next }
    $1 == "state:" && !gotstate { pstate = $2; gotstate = 1; next }
    $1 == "config:" { inconf = 1; next }
    $1 == "errors:" { inconf = 0; next }
    !inconf || NF == 0 || $1 == "NAME" || $1 == pool { next }
    $1 == "spares"  { section = "spares"; inpair = 0; next }
    $1 == "cache" || $1 == "logs" || $1 == "special" || $1 == "dedup" { section = "other"; inpair = 0; next }
    $1 ~ /^(spare|replacing)-[0-9]+$/ { inpair = 1; pkind = substr($1, 1, 5); sind = ind; kids = 0; next }
    is_vdev($1)     { inpair = 0; next }
    {
      id = $1; sub(/-part[0-9]+$/, "", id)
      if (section == "spares")       { role = "spare"; if ($2 == "INUSE") next }
      else if (section == "other")   { role = "aux" }
      else if (inpair && ind > sind) { kids++; role = (kids == 1) ? "replaced" : ((pkind == "spare") ? "standing-in" : "joining") }
      else                           { inpair = 0; role = "member" }
      printf "%s\t%s\t%s\t%s\t%s\n", id, pool, pstate, role, $2
    }'
}

# pure_verdict_view :: Tagged(V,R) -> Rows      (verdict table with pool role)
pure_verdict_view() {
  awk -F'\t' '
    $1 == "V" { n++; id[n] = $2; sh[n] = $3; st[n] = $4; why[n] = $5 }
    $1 == "R" {
      role[$2] = $3 ":" $5
      if ($6 != "ONLINE" && $6 != "AVAIL") role[$2] = role[$2] "(" $6 ")"
    }
    END {
      for (i = 1; i <= n; i++) {
        r = (id[i] in role) ? role[id[i]] : "-"
        printf "%-28s %-8s %-26s %s\n", sh[i], st[i], r, why[i]
      }
    }'
}

# pure_analyse :: Tagged(V,R) -> Lines
# P<TAB>... = pool summary line      A<TAB>... = advice line
pure_analyse() {
  awk -F'\t' -v target="$SPARE_TARGET" '
    $1 == "V" { nv++; vid[nv] = $2; st[$2] = $4; sh[$2] = $3 }
    $1 == "R" {
      nr++; rid[nr] = $2
      pool[$2] = $3; role[$2] = $5; state[$2] = $6; pst[$3] = $4
      if (!($3 in seen)) { seen[$3] = 1; np++; pname[np] = $3 }
    }
    END {
      # --- pool level -------------------------------------------------
      for (i = 1; i <= np; i++) {
        p = pname[i]
        members = 0; free = 0; fh = 0; fs = 0; fo = 0; inuse = 0
        for (j = 1; j <= nr; j++) {
          d = rid[j]
          if (pool[d] != p) continue
          s = (d in st) ? st[d] : "UNSCANNED"
          if (role[d] == "spare" && state[d] == "AVAIL") {
            free++
            if (s == "OK") fh++; else if (s == "SUSPECT") fs++; else fo++
          } else if (role[d] == "standing-in") inuse++
          else if (role[d] == "member" || role[d] == "replaced") members++
        }
        healthy[p] = fh
        printf "P\t%-12s %-9s members %d | free spares %d (healthy %d, suspect %d, unchecked %d) | in use %d\n", p, pst[p], members, free, fh, fs, fo, inuse
        if (pst[p] != "ONLINE")
          printf "A\t%-28s %-8s %s\n", p, pst[p], "pool is not ONLINE: look at this first (zpool status -v " p ")"
        if ((free + inuse) > 0 && fh < target)
          printf "A\t%-28s %-8s %s\n", p, "SPARES", sprintf("%d healthy free spare(s), target %d: plan to buy %d more", fh, target, target - fh)
      }
      # --- disk level, disks that are in a pool -----------------------
      for (j = 1; j <= nr; j++) {
        d = rid[j]; p = pool[d]; r = role[d]
        s = (d in st) ? st[d] : "UNSCANNED"
        n = (d in sh) ? sh[d] : d
        msg = ""
        if (s == "SUSPECT") {
          if (r == "member") {
            if (healthy[p] > 0) msg = sprintf("replace when the new disk arrives: zpool replace %s %s <new-disk> (a healthy spare covers it meanwhile)", p, d)
            else                msg = sprintf("URGENT, no healthy free spare: buy a disk, then zpool replace %s %s <new-disk>", p, d)
          } else if (r == "spare")       msg = "do not count it as a healthy spare"
          else if (r == "replaced")      msg = "being replaced: after the resilver ends, zpool detach it"
          else if (r == "standing-in")   msg = "is covering as spare but SUSPECT: watch the resilver closely"
        } else if (s == "WATCH") {
          msg = "run: smartctl -t long " d "; re-run this script weekly (only growth matters)"
        }
        if (msg != "") printf "A\t%-28s %-8s %s\n", n, s, msg
      }
      # --- disk level, SUSPECT disks that are in no pool --------------
      for (k = 1; k <= nv; k++) {
        d = vid[k]
        if ((d in pool) || st[d] != "SUSPECT") continue
        printf "A\t%-28s %-8s %s\n", sh[d], "SUSPECT", "not in any pool: retire it, or keep it only as a test disk"
      }
    }'
}

# pure_conclusion :: VerdictRecords -> Text    (counts, the KESIMPULAN part)
pure_conclusion() {
  awk -F'\t' '
    NF { total++; count[$3]++; names[$3] = names[$3] " " $2 }
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

# pure_report :: RoleRecords -> Records -> Report
# (role records come as an argument, disk records on stdin)
pure_report() {
  local roles="$1" recs vrecs marks tagged analysis advice
  recs=$(cat)
  vrecs=$(pure_verdict <<<"$recs")
  marks=$(pure_marks <<<"$vrecs")
  tagged=$(pure_tag V <<<"$vrecs"; pure_tag R <<<"$roles")
  analysis=$(pure_analyse <<<"$tagged")
  advice=$(pure_pick A <<<"$analysis")

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
  printf '%-28s %-8s %-26s %s\n' DISK STATUS ROLE WHY
  pure_verdict_view <<<"$tagged"

  pure_title "4. POOLS (from zpool status -v)"
  if [[ -n "$roles" ]]; then
    pure_pick P <<<"$analysis"
  else
    echo "(no zpool data: zpool not found, or no pools imported)"
  fi

  pure_title "5. KESIMPULAN / CONCLUSION"
  pure_conclusion <<<"$vrecs"
  printf '\nSUGGESTIONS (spare target: %s healthy free spares)\n' "$SPARE_TARGET"
  printf '%s\n' "${advice:-  (nothing to do)}"
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

# io_zpool_status :: IO Text   (empty text if zpool is missing)
io_zpool_status() { zpool status -v 2>/dev/null || true; }

# io_record_one :: Path -> IO Record
io_record_one() {
  io_probe "$1" | pure_record "$(basename "$1")"
}

# io_disks_from_args :: [Path] -> IO [Path]
io_disks_from_args() {
  if [[ $# -gt 0 ]]; then printf '%s\n' "$@"; else io_list_disks; fi
}

# io_main :: [Path] -> IO ()
io_main() {
  [[ $EUID -eq 0 ]] || { echo "run with sudo: smartctl needs root" >&2; return 1; }
  local roles
  roles=$(io_zpool_status | pure_pool_roles)
  io_disks_from_args "$@" | while read -r d; do io_record_one "$d"; done | pure_report "$roles"
}

io_main "$@"
