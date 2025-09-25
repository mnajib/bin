#!/usr/bin/env bash
# qcow2-ls.sh -- list qcow2 files like 'ls -l', showing full backing chain
# Usage:
#   ./qcow2-ls.sh file1.qcow2 ...
#   ./qcow2-ls.sh --tree file1.qcow2 ...

TREE_MODE=0

# Parse options
if [[ "$1" == "--tree" ]]; then
  TREE_MODE=1
  shift
fi

# Recursively get backing file for one qcow2
get_backing_file() {
  qemu-img info --output=json "$1" | jq -r '.["backing-filename"] // empty'
}

# Print full chain inline (ls -l style with arrows)
print_chain_inline() {
  local file="$1"
  local chain="$file"
  local backing="$file"

  while backing=$(get_backing_file "$backing"); [[ -n "$backing" ]]; do
    chain="$chain -> $backing"
  done

  local lsinfo
  lsinfo=$(ls -lh --time-style=+"%b %d %H:%M" "$file")

  echo "$lsinfo $chain"
}

# Print full chain as a tree diagram
print_chain_tree() {
  local file="$1"
  echo "$file"
  local depth=0
  local backing="$file"

  while backing=$(get_backing_file "$backing"); [[ -n "$backing" ]]; do
    depth=$((depth + 1))
    printf "%*s└── %s\n" $((depth * 4)) "" "$backing"
  done
}

# Main
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [--tree] <qcow2-files...>"
  exit 1
fi

for f in "$@"; do
  if [[ $TREE_MODE -eq 1 ]]; then
    print_chain_tree "$f"
  else
    print_chain_inline "$f"
  fi
done

