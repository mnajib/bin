#!/usr/bin/env bash
#
# git-file-status-tree.sh — list tracked, untracked, and ignored files grouped by directory
#
# Author: Najib & GPT-5
# Version: 2.0

# --- Helper Functions -------------------------------------------------------

# Pretty title section
print_section() {
  local title="$1"
  echo
  echo "============================================================"
  echo " $title"
  echo "============================================================"
}

# Render a list as tree-like structure
# Each argument = color code + lines from stdin
print_tree() {
  local color="$1"
  shift

  # Ensure consistent sorting and readable indentation
  awk -F'/' -v color="$color" '
  {
    indent = ""
    for (i = 1; i < NF; i++) {
      indent = indent "    "   # 4 spaces per level
    }
    printf "%s%s└── %s\033[0m\n", indent, color, $NF
  }
  '
}

# --- Main -------------------------------------------------------------------

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "❌ Not a Git repository."
  exit 1
fi

# Change directory to repo root for consistent paths
cd "$(git rev-parse --show-toplevel)" || exit 1

# Collect file lists
tracked_files=$(git ls-files)
untracked_files=$(git ls-files --others --exclude-standard)
ignored_files=$(git ls-files --others --ignored --exclude-standard)

# --- Show tracked -----------------------------------------------------------
print_section "✅ TRACKED FILES"
if [[ -n "$tracked_files" ]]; then
  echo "$tracked_files" | sort | print_tree "\033[1;32m"   # green
else
  echo "  (none)"
fi

# --- Show untracked ---------------------------------------------------------
print_section "⚠️  UNTRACKED FILES"
if [[ -n "$untracked_files" ]]; then
  echo "$untracked_files" | sort | print_tree "\033[1;33m"  # yellow
else
  echo "  (none)"
fi

# --- Show ignored -----------------------------------------------------------
print_section "🚫 IGNORED FILES"
if [[ -n "$ignored_files" ]]; then
  echo "$ignored_files" | sort | print_tree "\033[1;31m"    # red
else
  echo "  (none)"
fi

# --- Summary ---------------------------------------------------------------
tracked_count=$(echo "$tracked_files" | grep -c . || true)
untracked_count=$(echo "$untracked_files" | grep -c . || true)
ignored_count=$(echo "$ignored_files" | grep -c . || true)

print_section "📊 SUMMARY"
printf "  ✅ Tracked : %d\n" "$tracked_count"
printf "  ⚠️  Untracked : %d\n" "$untracked_count"
printf "  🚫 Ignored : %d\n" "$ignored_count"
echo

