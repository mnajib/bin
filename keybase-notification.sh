dbus-monitor interface=org.freedesktop.Notifications | grep --line-buffered '^\s*string "Keybase"$' | while read; do play -q /usr/share/sounds/freedesktop/stereo/message.oga; done
