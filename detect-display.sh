#!/usr/bin/env bash

# Pure function: returns list of available X11 display sockets
get_x11_displays() {
  local sock
  for sock in /tmp/.X11-unix/X*; do
    [[ -e "$sock" ]] && echo ":${sock##*/X}"
  done
}

# Pure function: returns list of running Xorg/Xwayland display numbers
get_x_process_displays() {
  ps -eo args | grep -E 'X(org|wayland)' | grep -o ':[0-9]\+' | sort -u
}

# Pure function: returns list of Wayland display sockets
get_wayland_displays() {
  local sock
  for sock in /run/user/"$UID"/wayland-*; do
    [[ -e "$sock" ]] && echo "${sock##*/}"
  done
}

# Main logic
main() {
  local wayland_displays x11_displays xproc_displays found=0

  echo "🔍 Scanning for active display sockets..."

  wayland_displays=$(get_wayland_displays)
  x11_displays=$(get_x11_displays)
  xproc_displays=$(get_x_process_displays)

  if [[ -n "$wayland_displays" ]]; then
    echo "🟢 Wayland displays:"
    echo "$wayland_displays" | sed 's/^/  - /'
    found=1
  fi

  if [[ -n "$x11_displays" ]]; then
    echo "🟢 X11 sockets:"
    echo "$x11_displays" | sed 's/^/  - /'
    found=1
  fi

  if [[ -n "$xproc_displays" ]]; then
    echo "🟢 Xorg/XWayland processes:"
    echo "$xproc_displays" | sed 's/^/  - /'
    found=1
  fi

  if [[ "$found" -eq 0 ]]; then
    echo "⚠️ No active display servers detected."
    return 1
  fi

  echo "✅ To use a display, run: export DISPLAY=:0 or export DISPLAY=wayland-1"
}

main "$@"

