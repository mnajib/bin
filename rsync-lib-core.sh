#!/usr/bin/env bash
# ~/bin/rsync-lib-core.sh
# Impure utilities — IO allowed.

# log_info :: String -> IO ()
io_log_info() {
  printf "[INFO] %s\n" "$*" >&2
}

# io_abort :: String -> IO a
io_abort() {
  printf "[ERROR] %s\n" "$*" >&2
  exit 1
}

# io_safe_rsync :: flags -> src -> des -> IO ()
io_safe_rsync() {
  #local flags="$1"
  #local src="$2"
  #local des="$3"
  #
  #io_log_info "Running rsync from $src to $des"
  # shellcheck disable=SC2086
  #sudo rsync $flags "$src" "$des"

  local args=("$@")   # capture everything
  local des="${args[-1]}"   # last argument is destination
  local src="${args[-2]}"   # second last is source
  local flags=("${args[@]:0:${#args[@]}-2}")  # everything before src/des

  io_log_info "Running rsync from $src to $des"
  sudo rsync "${flags[@]}" "$src" "$des"
}

