#!/usr/bin/env bash
#
# Push back to Julia's machine
# mirror changes back to Julia’s machine

set -euo pipefail

SRC='/mnt/data/julia/'
DES='julia@keira:/home/julia'
EXCLUDE_FILE="$HOME/bin/rsync-exclude/julia-home.txt"

# --- Import libraries -----------------------------------------
source "$HOME/bin/rsync-lib-core.sh"
source "$HOME/bin/rsync-lib-exclude.sh"

# --- Pure logic ------------------------------------------------
pure_build_rsync_flags() {
  local commonFlags="-vazPAX --progress --delete"
  local excludeFlags
  excludeFlags="$(pure_exclude_from_file "$EXCLUDE_FILE")"
  printf "%s %s" "$commonFlags" "$excludeFlags"
}

# --- Main ------------------------------------------------------
main() {
  io_log_info "Starting rsync job to push Julia’s home directory"
  io_log_info "Using exclude file: $EXCLUDE_FILE"

  [[ -f "$EXCLUDE_FILE" ]] || io_abort "Exclude file not found: $EXCLUDE_FILE"
  [[ -d "$SRC" ]] || io_abort "Source directory not found: $SRC"
  command -v rsync >/dev/null 2>&1 || io_abort "rsync not installed"

  local flags
  flags="$(pure_build_rsync_flags)"

  if [[ "${1:-}" == "--dry-run" ]]; then
    io_log_info "Running in dry-run mode"
    flags="$flags --dry-run"
  fi

  # shellcheck disable=SC2086
  if ! io_safe_rsync $flags "$SRC" "$DES"; then
    io_abort "rsync failed"
  fi

  io_log_info "rsync push completed successfully"
}

main "$@"

