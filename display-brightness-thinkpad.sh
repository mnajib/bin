#!/usr/bin/env bash

# Get info
xrandr --prop | grep " connected"
xrandr --prop | grep -A10 " connected" | grep "Brightness"

# Set new brightness
#xrandr --output LVDS-1 --brightness 0.4
