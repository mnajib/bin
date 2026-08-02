#!/usr/bin/env bash

##nix-shell nix-shell -i bash -p
##!zenity coreutils
set -euo pipefail

# Route to the current user's graphical display
# session
export DISPLAY=${DISPLAY:-:0} export
DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-"unix:path=/run/user/$(id -u)/bus"}
# Capture arguments safely
MESSAGE="${1:-"Sila masukkan jawapan anda:"}"
TITLE="${2:-"Mesej Sistem"}"
# Execute zenity smoothly on a single flat line
if RESPONSE=$(zenity --entry --title="$TITLE" --text="$MESSAGE" --width=400 2>/dev/null); then
    echo "SUCCESS: User replied:" echo
    "$RESPONSE"
else echo "ERROR: User canceled or closed the
    window." >&2 exit 1
fi
