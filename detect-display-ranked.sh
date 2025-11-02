#!/usr/bin/env bash

# Pure function: returns all X11 socket paths
get_x11_sockets() {
  ls /tmp/.X11-unix/X* 2>/dev/null
}

# Pure function: returns all Wayland socket paths
get_wayland_sockets() {
  ls /run/user/"$UID"/wayland-* 2>/dev/null | grep -v '\.lock$'
}

# Pure function: maps socket to owning process and compositor
get_socket_info() {
  local socket="$1"
  local name pid cmdline compositor

  name=$(basename "$socket")
  pid=$(lsof -t "$socket" 2>/dev/null | head -n1)
  cmdline=$(ps -p "$pid" -o args= 2>/dev/null)

  if [[ -z "$pid" ]]; then
    compositor="Unknown"
  else
    local comm
    comm=$(ps -p "$pid" -o comm=)
    case "$comm" in
      Xorg|X) compositor="Xorg" ;;
      Xwayland) compositor="XWayland" ;;
      Hyprland) compositor="Hyprland" ;;
      *) compositor="$comm" ;;
    esac
  fi

  echo "$name|$socket|$pid|$compositor|$cmdline"
}

# Pure function: ranks compositor types
get_rank() {
  case "$1" in
    Xorg) echo 1 ;;
    Hyprland) echo 2 ;;
    XWayland) echo 3 ;;
    *) echo 9 ;;
  esac
}

# Main logic
main() {
  local verbose=0
  [[ "$1" == "--verbose" ]] && verbose=1

  local sockets=()
  mapfile -t x11_sockets < <(get_x11_sockets)
  mapfile -t wayland_sockets < <(get_wayland_sockets)
  sockets=("${x11_sockets[@]}" "${wayland_sockets[@]}")

  if [[ "${#sockets[@]}" -eq 0 ]]; then
    echo "⚠️ No active display sockets found."
    return 1
  fi

  echo "🔍 Detected display sockets and owning compositors:"
  local display_map=()
  for sock in "${sockets[@]}"; do
    IFS='|' read -r name path pid compositor cmdline <<< "$(get_socket_info "$sock")"
    rank=$(get_rank "$compositor")
    display_map+=("$rank|$name|$compositor|$pid|$path|$cmdline")

    if [[ "$verbose" -eq 1 ]]; then
      echo "  - $name"
      echo "      Path      : $path"
      echo "      PID       : ${pid:-(none)}"
      echo "      Compositor: $compositor"
      echo "      Command   : ${cmdline:-(none)}"
    else
      echo "  - $name → $compositor"
    fi
  done

  echo ""
  echo "🏆 Ranked display candidates:"
  IFS=$'\n' sorted=($(sort <<<"${display_map[*]}"))
  unset IFS

  for entry in "${sorted[@]}"; do
    IFS='|' read -r rank name compositor pid path cmdline <<< "$entry"
    if [[ "$name" =~ ^X([0-9]+)$ ]]; then
      echo "  export DISPLAY=:${BASH_REMATCH[1]}  # $compositor"
    else
      echo "  export DISPLAY=$name  # $compositor"
    fi
  done
}

main "$@"

