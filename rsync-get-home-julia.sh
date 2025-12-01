#!/usr/bin/env bash

SRC='julia@keira:/home/julia/'
DES='/mnt/data/julia'

#sudo rsync -vazPAX --progress --exclude=.cache --exclude=.snapshots --delete $SRC $DES
##rm -Rf /home/julia/.cache /home/julia/.snapshots

EXCLUDE_FILE="$HOME/rsync-exclude/julia-home.txt"

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
  io_log_info "Using exclude file: $EXCLUDE_FILE"

  local flags
  flags="$(pure_build_rsync_flags)"

  # shellcheck disable=SC2086
  io_safe_rsync "$flags" "$SRC" "$DES"
}

main "$@"
