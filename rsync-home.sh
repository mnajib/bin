#!/usr/bin/env bash
set -euo pipefail

EXCLUDE_DIR="$HOME/bin/rsync-exclude"

# --- Import libraries -----------------------------------------
source "$HOME/bin/rsync-lib-core.sh"
source "$HOME/bin/rsync-lib-exclude.sh"

# --- Pure logic ------------------------------------------------
pure_build_rsync_flags() {
  local excludeFile="$1"
  local commonFlags="-vazPAX --progress --delete"
  local excludeFlags
  excludeFlags="$(pure_exclude_from_file "$excludeFile")"
  printf "%s %s" "$commonFlags" "$excludeFlags"
}

# --- Main ------------------------------------------------------
main() {
  if [[ $# -lt 2 ]]; then
    io_abort "Usage: $0 --mode=get|put --user=<username> [--dry-run]"
  fi

  local mode="" user="" dryrun=""
  for arg in "$@"; do
    case "$arg" in
      --mode=get) mode="get" ;;
      --mode=put) mode="put" ;;
      --user=*) user="${arg#*=}" ;;
      --dry-run) dryrun="--dry-run" ;;
      *) io_abort "Unknown argument: $arg" ;;
    esac
  done

  [[ -n "$user" ]] || io_abort "You must specify --user=<username>"
  local EXCLUDE_FILE="$EXCLUDE_DIR/${user}-home.txt"
  [[ -f "$EXCLUDE_FILE" ]] || io_abort "Exclude file not found: $EXCLUDE_FILE"
  command -v rsync >/dev/null 2>&1 || io_abort "rsync not installed"

  local SRC DES
  if [[ "$mode" == "get" ]]; then
    SRC="${user}@keira:/home/${user}/"
    DES="/mnt/data/${user}"
    [[ -d "$DES" ]] || io_abort "Destination directory not found: $DES"
    io_log_info "Mode: GET (pull from ${user}@keira)"
  elif [[ "$mode" == "put" ]]; then
    SRC="/mnt/data/${user}/"
    DES="${user}@keira:/home/${user}"
    [[ -d "$SRC" ]] || io_abort "Source directory not found: $SRC"
    io_log_info "Mode: PUT (push to ${user}@keira)"
  else
    io_abort "You must specify --mode=get or --mode=put"
  fi

  local flags
  flags="$(pure_build_rsync_flags "$EXCLUDE_FILE")"
  [[ -n "$dryrun" ]] && flags="$flags $dryrun"

  io_log_info "Using exclude file: $EXCLUDE_FILE"
  io_log_info "rsync command: rsync $flags $SRC $DES"

  # shellcheck disable=SC2086
  if ! io_safe_rsync $flags "$SRC" "$DES"; then
    io_abort "rsync failed"
  fi

  io_log_info "rsync $mode for $user completed successfully"
}

main "$@"

