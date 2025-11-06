#!/usr/bin/env bash
# browse-zfs-snapshots.sh — Interactive ZFS snapshot browser for recovery
# Author: Muhammad & Copilot
# Purpose: List ZFS snapshots, let user mount one read-only, browse, and cleanly unmount

set -euo pipefail

# ┌────────────────────────────────────────────┐
# │ Pure helper: show usage help              │
# └────────────────────────────────────────────┘
show_help() {
  cat <<EOF
Usage: $(basename "$0") [--dataset <zfs-dataset>] [--help]

Options:
  --dataset <name>   ZFS dataset to browse snapshots from (default: Riyadh/nixos-root)
  --help, -h         Show this help message

Example:
  $(basename "$0") --dataset Riyadh/nixos-home
EOF
  exit 0
}

# ┌────────────────────────────────────────────┐
# │ Pure helper: list snapshots for a dataset │
# └────────────────────────────────────────────┘
list_snapshots() {
  local dataset="$1"
  zfs list -t snapshot -o name -s creation -H | grep "^${dataset}@"
}

# ┌────────────────────────────────────────────┐
# │ Pure helper: mount snapshot read-only     │
# └────────────────────────────────────────────┘
mount_snapshot() {
  local snapshot="$1"
  local mount_point="$2"
  sudo mkdir -p "$mount_point"
  sudo mount -t zfs "$snapshot" "$mount_point"
}

# ┌────────────────────────────────────────────┐
# │ Pure helper: unmount and cleanup mount    │
# └────────────────────────────────────────────┘
cleanup_mount() {
  local mount_point="$1"
  sudo umount "$mount_point"
  sudo rmdir "$mount_point"
}

# ┌────────────────────────────────────────────┐
# │ Parse arguments                           │
# └────────────────────────────────────────────┘
readonly DEFAULT_DATASET="Riyadh/nixos-root"
DATASET="$DEFAULT_DATASET"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dataset)
      DATASET="$2"
      shift 2
      ;;
    --help|-h)
      show_help
      ;;
    *)
      echo "❌ Unknown option: $1"
      show_help
      ;;
  esac
done

# ┌────────────────────────────────────────────┐
# │ Main logic: immutable vars and flow       │
# └────────────────────────────────────────────┘

readonly MOUNT_BASE="/mnt/zfs-snapshots"
readonly SNAPSHOTS=($(list_snapshots "$DATASET"))

if [[ ${#SNAPSHOTS[@]} -eq 0 ]]; then
  echo "❌ No snapshots found for dataset: $DATASET"
  exit 1
fi

echo "📦 Available snapshots for $DATASET:"
for i in "${!SNAPSHOTS[@]}"; do
  printf "  [%d] %s\n" "$i" "${SNAPSHOTS[$i]}"
done

read -rp "🔍 Select snapshot number to mount: " CHOICE
readonly SNAP="${SNAPSHOTS[$CHOICE]}"
readonly MOUNT_POINT="${MOUNT_BASE}/${SNAP//@//}"

echo "📂 Mounting snapshot: $SNAP → $MOUNT_POINT"
mount_snapshot "$SNAP" "$MOUNT_POINT"

echo "✅ Snapshot mounted. You can now browse and copy files from:"
echo "   $MOUNT_POINT"

# Optional: open shell or file manager
if command -v xdg-open &>/dev/null; then
  xdg-open "$MOUNT_POINT"
else
  echo "💡 Tip: Use 'cd $MOUNT_POINT' to explore manually."
  bash
fi

read -rp "🧹 Press Enter to unmount and clean up..."
cleanup_mount "$MOUNT_POINT"
echo "✅ Done. Snapshot unmounted and cleaned."

