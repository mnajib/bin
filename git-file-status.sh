#!/usr/bin/env bash
#
# git-file-status.sh — list tracked, untracked, and ignored files/dirs in current git repo
#
# Author: Najib & GPT-5
# Version: 1.0

# --- Helper Functions -------------------------------------------------------

# Print section title
print_section() {
  local title="$1"
  echo
  echo "============================================================"
  echo " $title"
  echo "============================================================"
}

# Print list with color and indentation
print_list() {
  local color="$1"
  shift
  while IFS= read -r line; do
    [[ -n "$line" ]] && echo -e "  ${color}${line}\033[0m"
  done
}

# --- Main -------------------------------------------------------------------

# Ensure we’re inside a Git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "❌ Not a Git repository."
  exit 1
fi

# --- Show tracked files -----------------------------------------------------
print_section "✅ TRACKED FILES"
git ls-files | print_list "\033[1;32m"  # green

# --- Show untracked files ---------------------------------------------------
print_section "⚠️  UNTRACKED FILES"
git ls-files --others --exclude-standard | print_list "\033[1;33m"  # yellow

# --- Show ignored files -----------------------------------------------------
print_section "🚫 IGNORED FILES"
git ls-files --others --ignored --exclude-standard | print_list "\033[1;31m"  # red

# --- Summary counts ---------------------------------------------------------
tracked_count=$(git ls-files | wc -l)
untracked_count=$(git ls-files --others --exclude-standard | wc -l)
ignored_count=$(git ls-files --others --ignored --exclude-standard | wc -l)

print_section "📊 SUMMARY"
printf "  ✅ Tracked : %d\n" "$tracked_count"
printf "  ⚠️  Untracked : %d\n" "$untracked_count"
printf "  🚫 Ignored : %d\n" "$ignored_count"
echo

