#!/usr/bin/env bash

# Define the list of tmux sessions to check
SESSIONS=("audio" "xmonad-config" "nixconfig-NajibMalaysia" "bin" "btrfs" "zfs-zpool" "top-log")

# Loop through each session and check if it exists
for SESSION in "${SESSIONS[@]}"; do
  # Use tmux to get a list of all running sessions, then check if the desired session is present
  if ! tmux ls -F '#{?capture-client:&#{session_name}}' | grep -q "$SESSION"; then
    # If the session doesn't exist, create it
    echo "Creating $SESSION session..."
    tmux new-session -d -s "$SESSION" "tmux new-session \"$SESSION\""
  fi
done

# Check if all sessions are running (in case a previous run failed to create one)
for SESSION in "${SESSIONS[@]}"; do
  if ! tmux ls -F '#{?capture-client:&#{session_name}}' | grep -q "$SESSION"; then
    echo "Error creating $SESSION session!"
    exit 1
  fi
done

echo "All sessions created/checked successfully."
