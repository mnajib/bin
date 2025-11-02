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
get_compositor_for_socket() {
  local socket="$1"
  local pid
  pid=$(lsof -t "$socket" 2>/dev/null | head -n1)
  [[ -z "$pid" ]] && echo "Unknown" && return

  local cmd
  cmd=$(ps -p "$pid" -o comm=)

  case "$cmd" in
    Xorg|X) echo "Xorg" ;;
    Xwayland) echo "XWayland" ;;
    Hyprland) echo "Hyprland" ;;
    *) echo "$cmd" ;;
  esac
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
  local sockets=()
  local display_map=()

  # Collect sockets
  mapfile -t x11_sockets < <(get_x11_sockets)
  mapfile -t wayland_sockets < <(get_wayland_sockets)
  sockets=("${x11_sockets[@]}" "${wayland_sockets[@]}")

  if [[ "${#sockets[@]}" -eq 0 ]]; then
    echo "⚠️ No active display sockets found."
    return 1
  fi

  echo "🔍 Detected display sockets and owning compositors:"
  for sock in "${sockets[@]}"; do
    local name compositor rank
    name=$(basename "$sock")
    compositor=$(get_compositor_for_socket "$sock")
    rank=$(get_rank "$compositor")
    display_map+=("$rank|$name|$compositor")
  done

  # Sort and display ranked results
  IFS=$'\n' sorted=($(sort <<<"${display_map[*]}"))
  unset IFS

  echo ""
  echo "🏆 Ranked display candidates:"
  for entry in "${sorted[@]}"; do
    IFS='|' read -r rank name compositor <<< "$entry"
    if [[ "$name" =~ ^X([0-9]+)$ ]]; then
      echo "  export DISPLAY=:${BASH_REMATCH[1]}  # $compositor"
    else
      echo "  export DISPLAY=$name  # $compositor"
    fi
  done
}

main "$@"

