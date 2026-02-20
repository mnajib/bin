#!/usr/bin/env bash

SRC='julia@keira:/home/julia/'
DES='/mnt/data/julia'

#sudo rsync -vazPAX --progress --exclude=.cache --exclude=.snapshots --delete $SRC $DES
##rm -Rf /home/julia/.cache /home/julia/.snapshots

EXCLUDE_FILE="$HOME/bin/rsync-exclude/julia-home.txt"

# --- Import libraries -----------------------------------------
source "$HOME/bin/rsync-lib-core.sh"
source "$HOME/bin/rsync-lib-exclude.sh"

# --- Pure logic ------------------------------------------------
pure_build_rsync_flags() {
  #local commonFlags="-vazPAX --progress --delete"
  #local excludeFlags
  #excludeFlags="$(pure_exclude_from_file "$EXCLUDE_FILE")"
  #printf "%s %s" "$commonFlags" "$excludeFlags"

  local commonFlags=(-vazPAX --progress --delete)
  local excludeFlags
  mapfile -t excludeFlags < <(pure_exclude_from_file "$EXCLUDE_FILE")
  printf "%s\n" "${commonFlags[@]}" "${excludeFlags[@]}"
}

# --- Main ------------------------------------------------------
main() {
  io_log_info "Starting rsync job for Julia’s home directory"
  io_log_info "Using exclude file: $EXCLUDE_FILE"

  [[ -f "$EXCLUDE_FILE" ]] || io_abort "Exclude file not found: $EXCLUDE_FILE"
  [[ -d "$DES" ]] || io_abort "Destination directory not found: $DES"
  command -v rsync >/dev/null 2>&1 || io_abort "rsync not installed"

  local flags
  #flags="$(pure_build_rsync_flags)"
  #
  # Read flags into an array
  mapfile -t flags < <(pure_build_rsync_flags)

  # print the exact command line before running it
  io_log_info "rsync command: rsync ${flags[*]} $src $des"

  # shellcheck disable=SC2086
  #io_safe_rsync "$flags" "$SRC" "$DES"

  if [[ "${1:-}" == "--dry-run" ]]; then
    io_log_info "Running in dry-run mode"
    flags="$flags --dry-run"
  fi

  #if ! io_safe_rsync $flags "$SRC" "$DES"; then
  #  io_abort "rsync failed"
  #fi
  #
  if ! io_safe_rsync "${flags[@]}" "$SRC" "$DES"; then
    io_abort "rsync failed"
  fi

  io_log_info "rsync completed successfully"
}

main "$@"
