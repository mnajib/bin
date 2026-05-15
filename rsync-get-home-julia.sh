#!/usr/bin/env bash

# Fail fast on bad pipelines, unassigned variables, or failed commands
set -euo pipefail

#
# NOTE:
#
#   sudo rsync -vazPAX --progress --exclude=.cache --exclude=.snapshots --delete $SRC $DES
#   #rm -Rf /home/julia/.cache /home/julia/.snapshots
#

SRC='julia@keira:/home/julia/'
DES='/mnt/data/julia'
EXCLUDE_FILE="${HOME}/bin/rsync-exclude/julia-home.txt"

# --- Import libraries -----------------------------------------
source "$HOME/bin/rsync-lib-core.sh"
source "$HOME/bin/rsync-lib-exclude.sh"

# --- Pure logic ------------------------------------------------
pure_build_rsync_flags() {
  local commonFlags=(-vazPAX --progress --delete)
  local excludeFlags=()

  # Cleanly swallow lines out of the pure filter pipeline
  mapfile -t excludeFlags < <(pure_exclude_from_file "$EXCLUDE_FILE")
  printf "%s\n" "${commonFlags[@]}" "${excludeFlags[@]}"
  #
  # OR
  #
  # Print out common flags line-by-line for mapfile ingestion
  #printf "%s\n" "${commonFlags[@]}"
  #
  # Assuming pure_exclude_from_file also outputs line-by-line format:
  # e.g., --exclude=pattern
  #pure_exclude_from_file "$EXCLUDE_FILE"
  #
  # OR
  #
  # Output all flags: first common flags (one per line), then exclude flags
  #printf "%s\n" "${commonFlags[@]}"
  #[[ -n "$excludeFlags" ]] && printf "%s\n" "$excludeFlags"
  #

}

# --- Main ------------------------------------------------------
main() {
  io_log_info "Starting rsync job for Julia’s home directory"
  io_log_info "Using exclude file: $EXCLUDE_FILE"

  # Structural Pre-checks
  [[ -f "$EXCLUDE_FILE" ]] || io_abort "Exclude file not found: $EXCLUDE_FILE"
  [[ -d "$DES" ]] || io_abort "Destination directory not found: $DES"
  command -v rsync >/dev/null 2>&1 || io_abort "rsync not installed"

  # Define an array
  local flags=()
  # Read flags into an array
  mapfile -t flags < <(pure_build_rsync_flags)

  # Mutate array using proper array syntax BEFORE logging or running
  if [[ "${1:-}" == "--dry-run" ]]; then
    io_log_info "Running in dry-run mode"
    #flags+=(--dry-run)
    flags+=("--dry-run")
  fi

  # Print the exact command line before running it
  io_log_info "rsync command: rsync ${flags[*]} $SRC $DES"

  # Execute (rsync) utilizing proper (precise) element (array) expansion
  if ! io_safe_rsync "${flags[@]}" "$SRC" "$DES"; then
    io_abort "rsync failed"
  fi

  io_log_info "rsync completed successfully"
}

main "$@"
