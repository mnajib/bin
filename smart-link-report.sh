#!/usr/bin/env bash
# smart-link-report.sh (v5) -- compare link-health counters across SATA disks,
#                              relate them to the zpool layout, and track growth
#
# usage:  sudo ./smart-link-report.sh [--diff] [--save] [--zpool-file FILE] [disk-path ...]
#
#   (no flag)         full report: sections 1-5
#   --save            full report, then store the counters as the new baseline
#   --diff            growth since the saved baseline only: sections G1-G3
#   --diff --save     growth, then store a new baseline (good for a weekly run)
#   --zpool-file FILE read zpool status text from FILE instead of running zpool
#                     (for testing the parser with a saved or hand-made status)
#   disk-path         pass /dev/disk/by-id/... paths, so names match zpool status
#                     (no paths = every whole disk under /dev/disk/by-id/ata-*)
#
# full report sections:
#   1. TABLE       full numbers, incl. rates per 1000 power-on hours
#   2. CHARTS      ASCII bar charts, worst disk first
#   3. VERDICT     OK / WATCH / SUSPECT / NO-DATA per disk, with its pool role
#   4. POOLS       per-pool summary from zpool status -v (members, spares)
#   5. KESIMPULAN  counts and suggested actions
#
# growth sections (--diff):
#   G1. GROWTH TABLE   counters gained since the baseline
#   G2. GROWTH CHARTS  bars of NEW mid-command resets / timeouts
#   G3. KESIMPULAN     STABLE / GROWING / NEW / GONE / RESET? and what it suggests
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
#   dXXX     = value now minus value at the baseline (dPOH = hours powered on)
#
# '-' means the drive does not report that value (older drives often
# lack the Device Statistics log).
#
# record format (TAB separated, one line per disk):
#   1 short-name  2 poh  3 cmd_tmo  4 rst_mid  5 hw_rst  6 asr
#   7 comreset    8 crc  9 full by-id name
#
# baseline file: line 1 = "#" + save time, then one record per disk
#
#-------------------------------------------------------------------------------
#
# Example usage workflow
#
#  STEP 1  update the script, then test the parser:
#            sudo ./smart-link-report.sh --zpool-file /tmp/zpool-degraded.txt
#
#  STEP 2  normal run, then store today as week 0 (t0):
#            sudo ./smart-link-report.sh --save
#
#  STEP 3  quick check any time, growth only, baseline untouched:
#            sudo ./smart-link-report.sh --diff
#
#  STEP 4  weekly routine, growth first, then roll the baseline forward:
#            sudo ./smart-link-report.sh --diff --save
#
#
# Example scenarios
#
#   SCENARIO 1: a week passes, DLPE shows dRST = 0, everything else STABLE
#    --> the stalls stopped. Keep the Path 2 plan; no rush to buy.
#
#  SCENARIO 2: DLPE shows dRST = 7, all other disks STABLE
#    --> the problem is still there and it is isolated to that disk (or its
#        cable and bay). This supports replacing it when the new disk arrives.
#
#  SCENARIO 3: DLPE and Toshiba 57L7 both GROWING in the same week
#    --> two disks stalling together point at something shared (HBA port,
#        power, backplane), so buying a disk alone will not fix it.
#
#  SCENARIO 4: you run the zpool replace, then --diff
#    --> the new disk shows NEW, and DLPE shows GONE or a ROLE change.
#        Run --save again to start a clean baseline.
#
# Example usage plan
#
#   1. Run --save right after you update the script, so the baseline is "just
#      after the incident". Otherwise you're comparing against nothing.
#
#   2. Weekly is enough. The counters are cumulative, so even a daily check
#      wouldn't catch anything weekly would miss, only sooner. Daily only helps
#      if you're about to decide quickly.
#
#   3. Keep --diff without --save for ad-hoc checks, because --save overwrites
#      the baseline and you lose the longer comparison window. If you want to
#      keep older baselines, copy baseline.tsv somewhere before a roll.
#
#   4. 4GROW_MIN=1 is deliberately strict. One new reset flags the disk. If
#      that turns noisy, raise it to 3 or 5.
#
#-------------------------------------------------------------------------------
#


set -euo pipefail

# ---------------------------------------------------------------
# CONSTANTS (single source of truth -- edit here only)
# ---------------------------------------------------------------
readonly BAR_WIDTH=40          # width of the longest bar, in characters
readonly RST_KH_WARN=5         # mid-cmd resets per 1000 h: >= this -> WATCH
readonly RST_KH_BAD=20         # mid-cmd resets per 1000 h: >= this -> SUSPECT
readonly SPARE_TARGET=2        # wanted number of HEALTHY free spares per pool
                               # (only checked for pools that have spares)
readonly GROW_MIN=1            # a stall counter that gained >= this -> GROWING
readonly SNAP_DIR=/var/lib/smart-link-report
readonly BASELINE="$SNAP_DIR/baseline.tsv"
readonly ROW_FMT='%-28s %-7s %-9s %-8s %-7s %-8s %-7s %-6s %-9s %-5s\n'
readonly DELTA_FMT='%-28s %-7s %-6s %-6s %-6s %-7s %-6s %s\n'

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
# a bar is flagged when its disk has status SUSPECT, WATCH, GROWING or RESET?
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
        s = st[n[i]]
        tag = (s == "SUSPECT" || s == "WATCH" || s == "GROWING" || s == "RESET?") ? "  <-- " s : ""
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

# pure_baseline_date :: BaselineText -> Text   (line 1 is "#<save time>")
pure_baseline_date() { awk 'NR == 1 && /^#/ { print substr($0, 2); exit }'; }

# pure_delta :: Tagged(B,C) -> DeltaRecords
# B = baseline records (plus its "#date" line), C = current records
# DeltaRecord = TAB separated:
#   1 by-id  2 short-name  3 dPOH  4 dRST  5 dTMO  6 dCRC  7 dHW  8 dASR  9 STATUS
# STATUS is decided from dRST, dTMO, dCRC only (dHW and dASR are noisy here)
pure_delta() {
  awk -F'\t' -v gmin="$GROW_MIN" '
    function num(x)  { return x ~ /^[0-9]+$/ }
    function last(s,   n, a) { n = split(s, a, "/"); return a[n] }
    function diff(a, b) { return (num(a) && num(b)) ? b - a : "-" }
    $1 == "B" && substr($2, 1, 1) == "#" { next }
    $1 == "B" {
      nb++; bid[nb] = $10; bsh[$10] = $2
      bpoh[$10] = $3; btmo[$10] = last($4); brst[$10] = $5
      bhw[$10] = $6; basr[$10] = $7; bcrc[$10] = $9
      next
    }
    $1 == "C" {
      nc++; cid[nc] = $10; cur[$10] = 1
      csh[nc] = $2; cpoh[nc] = $3; ctmo[nc] = last($4); crst[nc] = $5
      chw[nc] = $6; casr[nc] = $7; ccrc[nc] = $9
    }
    END {
      for (i = 1; i <= nc; i++) {
        d = cid[i]
        if (!(d in bsh)) {
          printf "%s\t%s\t-\t-\t-\t-\t-\t-\tNEW\n", d, csh[i]
          continue
        }
        dpoh = diff(bpoh[d], cpoh[i]); drst = diff(brst[d], crst[i])
        dtmo = diff(btmo[d], ctmo[i]); dcrc = diff(bcrc[d], ccrc[i])
        dhw  = diff(bhw[d], chw[i]);   dasr = diff(basr[d], casr[i])
        avail = 0; grow = 0; neg = 0
        split(drst " " dtmo " " dcrc, v, " ")
        for (k = 1; k <= 3; k++) {
          if (v[k] == "-") continue
          avail++
          if (v[k] < 0)     neg++
          if (v[k] >= gmin) grow++
        }
        s = neg ? "RESET?" : (avail == 0 ? "NO-DATA" : (grow ? "GROWING" : "STABLE"))
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", d, csh[i], dpoh, drst, dtmo, dcrc, dhw, dasr, s
      }
      for (i = 1; i <= nb; i++) {
        d = bid[i]
        if (!(d in cur)) printf "%s\t%s\t-\t-\t-\t-\t-\t-\tGONE\n", d, bsh[d]
      }
    }'
}

# pure_delta_header :: Text
pure_delta_header() {
  # shellcheck disable=SC2059
  printf "$DELTA_FMT" DISK dPOH dRST dTMO dCRC dHW dASR STATUS
}

# pure_delta_table :: DeltaRecords -> Rows
pure_delta_table() {
  awk -F'\t' -v fmt="$DELTA_FMT" 'NF { printf fmt, $2, $3, $4, $5, $6, $7, $8, $9 }'
}

# pure_delta_metric :: Kind -> DeltaRecords -> Pairs     ("value<TAB>name")
# Kind = rst | tmo     (only non-negative numeric deltas are charted)
pure_delta_metric() {
  awk -F'\t' -v k="$1" '
    NF {
      v = (k == "rst") ? $4 : $5
      if (v ~ /^[0-9]+$/) printf "%.1f\t%s\n", v, $2
    }'
}

# pure_delta_marks :: DeltaRecords -> Text      ("short=STATUS;short=STATUS;...")
pure_delta_marks() { awk -F'\t' 'NF { printf "%s=%s;", $2, $9 }'; }

# pure_growth_conclusion :: DeltaRecords -> Text   (the growth KESIMPULAN)
pure_growth_conclusion() {
  awk -F'\t' '
    NF { total++; c[$9]++; names[$9] = names[$9] " " $2 }
    END {
      printf "Disks compared : %d  (STABLE %d, GROWING %d, NEW %d, GONE %d, RESET? %d, NO-DATA %d)\n",
             total, c["STABLE"], c["GROWING"], c["NEW"], c["GONE"], c["RESET?"], c["NO-DATA"]
      if (c["GROWING"] >= 2)
        printf "GROWING        :%s\n  -> %d disks stalled in the same interval: suspect something shared (HBA port, power, backplane) before blaming the disks\n", names["GROWING"], c["GROWING"]
      else if (c["GROWING"] == 1)
        printf "GROWING        :%s\n  -> one disk only: suspect that disk, its cable or its bay\n", names["GROWING"]
      else
        print "GROWING        : none -- no new stalls since the baseline"
      if (c["GONE"])
        printf "GONE           :%s\n  -> was in the baseline but not found now: check cabling and zpool status\n", names["GONE"]
      if (c["RESET?"])
        printf "RESET?         :%s\n  -> a counter went DOWN (disk swapped or counters wiped): save a fresh baseline\n", names["RESET?"]
      if (c["NEW"])
        printf "NEW            :%s\n  -> not in the baseline yet: compared from the next --save\n", names["NEW"]
    }'
}

# pure_growth_report :: Baseline -> Records -> Report
# (baseline text comes as an argument, current records on stdin)
pure_growth_report() {
  local base="$1" recs bdate tagged deltas marks
  recs=$(cat)
  if [[ -z "$base" ]]; then
    echo "no baseline yet: run  sudo ./smart-link-report.sh --save  first"
    return 0
  fi
  bdate=$(pure_baseline_date <<<"$base")
  tagged=$(pure_tag B <<<"$base"; pure_tag C <<<"$recs")
  deltas=$(pure_delta <<<"$tagged")
  marks=$(pure_delta_marks <<<"$deltas")

  pure_title "G1. GROWTH TABLE (counters gained since baseline saved ${bdate:-?})"
  pure_delta_header
  pure_delta_table <<<"$deltas"

  pure_title "G2. GROWTH CHARTS (only NEW events count)"
  pure_delta_metric rst <<<"$deltas" | pure_bars "dRST (new mid-command resets)" "$marks"
  printf '\n'
  pure_delta_metric tmo <<<"$deltas" | pure_bars "dTMO (new command timeouts)" "$marks"

  pure_title "G3. KESIMPULAN / CONCLUSION"
  pure_growth_conclusion <<<"$deltas"
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

# io_zpool_status :: Maybe FilePath -> IO Text
# a given file replaces the real command; empty text if zpool is missing
io_zpool_status() {
  local file="${1:-}"
  if [[ -n "$file" ]]; then cat "$file"; else zpool status -v 2>/dev/null || true; fi
}

# io_record_one :: Path -> IO Record
io_record_one() {
  io_probe "$1" | pure_record "$(basename "$1")"
}

# io_disks_from_args :: [Path] -> IO [Path]
io_disks_from_args() {
  if [[ $# -gt 0 ]]; then printf '%s\n' "$@"; else io_list_disks; fi
}

# io_collect_records :: [Path] -> IO Records
io_collect_records() {
  io_disks_from_args "$@" | while read -r d; do io_record_one "$d"; done
}

# io_read_baseline :: IO Text   (empty text if there is no baseline yet)
io_read_baseline() {
  if [[ -r "$BASELINE" ]]; then cat "$BASELINE"; fi
}

# io_save_baseline :: Records -> IO ()
# writes to a temp file first, then moves it, so a crash never leaves half a baseline
io_save_baseline() {
  local tmp
  mkdir -p "$SNAP_DIR"
  tmp=$(mktemp "$SNAP_DIR/.baseline.XXXXXX")
  { printf '#%s\n' "$(date --iso-8601=seconds)"; cat; } > "$tmp"
  mv -f "$tmp" "$BASELINE"
  echo "baseline saved: $BASELINE"
}

# io_main :: [Arg] -> IO ()
io_main() {
  local want_diff=0 want_save=0 zfile="" disks=() recs roles base
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --diff)        want_diff=1 ;;
      --save)        want_save=1 ;;
      --zpool-file)  zfile="${2:?--zpool-file needs a FILE}"; shift ;;
      *)             disks+=("$1") ;;
    esac
    shift
  done

  [[ $EUID -eq 0 ]] || { echo "run with sudo: smartctl needs root" >&2; return 1; }

  recs=$(io_collect_records "${disks[@]}")

  if [[ $want_diff -eq 1 ]]; then
    base=$(io_read_baseline)
    pure_growth_report "$base" <<<"$recs"
  else
    roles=$(io_zpool_status "$zfile" | pure_pool_roles)
    pure_report "$roles" <<<"$recs"
  fi

  if [[ $want_save -eq 1 ]]; then
    io_save_baseline <<<"$recs"
  fi
}

io_main "$@"
