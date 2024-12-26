#!/usr/bin/env bash

#sudo apt-get install xdotool zenity libnotify

# Get the current window ID
WINDOW_ID=$(xdotool getwindowfocus)
#echo "WINDOW_ID: $WINDOW_ID"

# Get the current window title
CURRENT_TITLE="$(xdotool getwindowname $WINDOW_ID)"
#echo "CURRENT_TITLE: $CURRENT_TITLE"

# Open a dialog to enter the new title
NEW_TITLE=$(zenity --entry --title="Change Window Title" --text="${CURRENT_TITLE}")
#NEW_TITLE=$(zenity --entry --title="Change Window Title" --text=$CURRENT_TITLE --cancel-label="Abort")
#if [ $? -eq 1 ]; then
#  # User clicked Cancel
#  exit 0
#fi
#echo "NEW TITLE: $NEW_TITLE"

# Check if the user cancelled or entered an empty title
if [ -z "$NEW_TITLE" ]; then
  # Do nothing if the user cancelled or entered an empty title
  exit 0
fi

# Truncate the new title if it exceeds 255 characters (example length limit)
NEW_TITLE=${NEW_TITLE:0:255}

# Set the new title
#xdotool setwindowname $WINDOW_ID "$NEW_TITLE"
#xdotool set_window --name "${NEW_TITLE}" ${WINDOW_ID}
#if xdotool setwindowname --utf8 $WINDOW_ID "$NEW_TITLE"; then
#if xdotool set_window --name "${NEW_TITLE}" ${WINDOW_ID}; then
if $(xdotool set_window --name "${NEW_TITLE}" ${WINDOW_ID}); then
  # Refocus the window
  xdotool windowfocus $WINDOW_ID
  # Display a notification
  #notify-send "Window title changed" "New title: $NEW_TITLE"
  #xmessage -center "Window title changed" "New title: $NEW_TITLE"
else
  # Handle error
  #notify-send "Error" "Failed to change window title"
  #xmessage -center "Error" "Failed to change window title"
  exit 1
fi
