#!/usr/bin/env bash

TARGET_DIR="${1:-.}"  # Use current directory if no argument provided

# Process directories
sudo find "$TARGET_DIR" -type d -exec chmod g+rwx {} +

# Process files
sudo find "$TARGET_DIR" -type f -exec chmod g+rw {} +
