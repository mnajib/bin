#!/usr/bin/env/bash

#pdf2ps "${FILE}" - | ps2pdf - B1100_SPM2025_-_JULIANI_-_converted.pdf

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 input.pdf"
  exit 1
fi

input="$1"

if [[ ! -f "$input" ]]; then
  echo "Error: file not found: $input"
  exit 1
fi

# Strip .pdf if present and append suffix
base="${input%.pdf}"
output="${base}_converted.pdf"

pdftops "$input" - | ps2pdf - "$output"

echo "Written: $output"

