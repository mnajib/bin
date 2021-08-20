#!/run/current-system/sw/bin/env bash

# First clear/rest xrandr settings
xrandr -s 0

xrandr --output LVDS-1 --scale 1x1
xrandr --output LVDS-1 --scale 1x1 --panning 1280x800

