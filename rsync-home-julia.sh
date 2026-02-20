#!/usr/bin/env bash
set -euo pipefail

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
  if [[ $# -lt 1 ]]; then
    io_abort "Usage: $0 --mode=get|put [--dry-run]"
  fi

  local mode=""
  local dryrun=""

  for arg in "$@"; do
    case "$arg" in
      --mode=get) mode="get" ;;
      --mode=put) mode="put" ;;
      --dry-run) dryrun="--dry-run" ;;
      *) io_abort "Unknown argument: $arg" ;;
    esac
  done

  [[ -f "$EXCLUDE_FILE" ]] || io_abort "Exclude file not found: $EXCLUDE_FILE"
  command -v rsync >/dev/null 2>&1 || io_abort "rsync not installed"

  local SRC DES
  if [[ "$mode" == "get" ]]; then
    SRC='julia@keira:/home/julia/'
    DES='/mnt/data/julia'
    [[ -d "$DES" ]] || io_abort "Destination directory not found: $DES"
    io_log_info "Mode: GET (pull from Julia’s machine)"
  elif [[ "$mode" == "put" ]]; then
    SRC='/mnt/data/julia/'
    DES='julia@keira:/home/julia'
    [[ -d "$SRC" ]] || io_abort "Source directory not found: $SRC"
    io_log_info "Mode: PUT (push to Julia’s machine)"
  else
    io_abort "You must specify --mode=get or --mode=put"
  fi

  local flags
  flags="$(pure_build_rsync_flags)"
  [[ -n "$dryrun" ]] && flags="$flags $dryrun"

  io_log_info "Using exclude file: $EXCLUDE_FILE"
  io_log_info "rsync command: rsync $flags $SRC $DES"

  # shellcheck disable=SC2086
  if ! io_safe_rsync $flags "$SRC" "$DES"; then
    io_abort "rsync failed"
  fi

  io_log_info "rsync $mode completed successfully"
}

main "$@"

