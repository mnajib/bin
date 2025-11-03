#!/usr/bin/env bash
# masihi-hijri-convert.sh — Convert between Gregorian (BCE/CE) and Hijri years
# Author: Muhammad & Copilot
# License: MIT

set -euo pipefail

# --- Helpers ---
usage() {
  echo "Usage:"
  echo "  $0 --to-hijri <year> [--bce]"
  echo "  $0 --to-masihi <hijri_year>"
  echo "Flags:"
  echo "  --bce       Treat Gregorian year as BCE"
  exit 1
}

# --- Conversion Logic ---
to_hijri() {
  local year=$1
  local is_bce=${2:-false}
  local hijri_year

  if [[ "$is_bce" == "true" ]]; then
    hijri_year=$((622 + year))
    echo "Gregorian ${year} BCE ≈ Hijri ${hijri_year} AH (approx)"
  else
    # More accurate lunar adjustment
    hijri_year=$(awk "BEGIN {printf \"%d\", ($year - 622) * 33 / 32}")
    echo "Gregorian ${year} CE ≈ Hijri ${hijri_year} AH (approx)"
  fi
}

to_masihi() {
  local hijri_year=$1
  local gregorian_year=$(awk "BEGIN {printf \"%d\", 622 + ($hijri_year * 32 / 33)}")
  echo "Hijri ${hijri_year} AH ≈ Gregorian ${gregorian_year} CE (approx)"
}

print_timeline() {
  local start_year=$1
  local end_year=$2

  printf "%-12s | %-12s\n" "Gregorian" "Hijri"
  printf "%-12s | %-12s\n" "----------" "----------"

  for (( y=start_year; y<=end_year; y++ )); do
    if (( y < 0 )); then
      hijri=$((622 + (-1 * y)))
      printf "%-12s | %-12s\n" "${y} BCE" "${hijri} AH"
    elif (( y < 622 )); then
      hijri=$((622 - y))
      printf "%-12s | %-12s\n" "${y} CE" "${hijri} BH"
    else
      hijri=$(awk "BEGIN {printf \"%d\", ($y - 622) * 33 / 32}")
      printf "%-12s | %-12s\n" "${y} CE" "${hijri} AH"
    fi
  done
}

# --- Main ---
main() {
  if [[ $# -lt 2 ]]; then usage; fi

  case "$1" in
    --to-hijri)
      shift
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        year=$1; shift
        is_bce=false
        [[ "${1:-}" == "--bce" ]] && is_bce=true
        to_hijri "$year" "$is_bce"
      else
        usage
      fi
      ;;
    --to-masihi)
      shift
      [[ "$1" =~ ^[0-9]+$ ]] && to_masihi "$1" || usage
      ;;
    --timeline)
      shift
      [[ $# -eq 2 && "$1" =~ ^-?[0-9]+$ && "$2" =~ ^-?[0-9]+$ ]] \
        && print_timeline "$1" "$2" || usage
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"

