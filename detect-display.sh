#!/usr/bin/env bash

print_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Detect active display sockets and their owning compositors (Xorg, Hyprland, XWayland), without relying on environment variables.

Options:
  --verbose       Show detailed info for each socket (path, PID, command line)
  --rank          Show ranked display exports by compositor preference
  -h, --help      Show this help message and exit

Examples:
  $(basename "$0")             # Show detected sockets and compositors
  $(basename "$0") --verbose   # Show full socket diagnostics
  $(basename "$0") --rank      # Show ranked display exports
EOF
}

get_x11_sockets() {
  ls /tmp/.X11-unix/X* 2>/dev/null
}

get_wayland_sockets() {
  ls /run/user/"$UID"/wayland-* 2>/dev/null | grep -v '\.lock$'
}

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

get_rank() {
  case "$1" in
    Xorg) echo 1 ;;
    Hyprland) echo 2 ;;
    XWayland) echo 3 ;;
    *) echo 9 ;;
  esac
}

run_detection() {
  local verbose="${1:-0}"
  local rank="${2:-0}"
  local sockets=()
  mapfile -t x11_sockets < <(get_x11_sockets)
  mapfile -t wayland_sockets < <(get_wayland_sockets)
  sockets=("${x11_sockets[@]}" "${wayland_sockets[@]}")

  if [[ "${#sockets[@]}" -eq 0 ]]; then
    echo "⚠️  No active display sockets found."
    return 1
  fi

  if [[ "$EUID" -ne 0 ]]; then
    echo ""
    echo "⚠️  Some display sockets may be misclassified due to permission limits."
    echo "   Run with sudo to see full compositor ownership and command details."
  fi

  echo ""
  echo "🔍 Detected display sockets and owning compositors:"
  local display_map=()
  for sock in "${sockets[@]}"; do
    IFS='|' read -r name path pid compositor cmdline <<< "$(get_socket_info "$sock")"
    rank_val=$(get_rank "$compositor")
    display_map+=("$rank_val|$name|$compositor|$pid|$path|$cmdline")

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

  if [[ "$rank" -eq 1 ]]; then
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
  fi
}

main() {
  local verbose=0
  local rank=0

  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_help
        return 0
        ;;
      --verbose)
        verbose=1
        ;;
      --rank)
        rank=1
        ;;
      *)
        echo "❌ Unknown option: $arg"
        echo "Run with --help to see usage."
        return 1
        ;;
    esac
  done

  run_detection "$verbose" "$rank"
}

main "$@"

