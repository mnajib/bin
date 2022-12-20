#!/usr/bin/env bash

#
# Usage:
#   init-second-monitor1280x1024-forKeira.sh dual
#   init-second-monitor1280x1024-forKeira.sh single
#

echo "-----------------> ${1} <-----------------"

export DISPLAY=:0
#export XAUTHORITY=/home/juliani/.Xauthority

internal="LVDS-1" # right
external="VGA-1"  # left

#dmode="$(cat /sys/class/drm/card0-VGA-1/status)"

# set dual monitors
dual () {
    #xrandr --output VGA-0 --primary --left-of HDMI-0 --output HDMI-0 --auto
    #xrandr --output LVDS-1 --mode 1280x800 --primary --auto --output VGA-1 --mode 1280x1024 --left-of LVDS-1 --auto
    #xrandr --output ${internal} --mode 1280x800 --primary --pos 1280x414 --output ${external} --mode 1280x1024 --pos 0x0 # zahrah
    xrandr --output LVDS-1 --mode 1280x800 --primary --pos 1280x414 --output VGA-1 --mode 1280x1024 --pos 0x0 # zahrah
}

# set single monitor
single () {
    #xrandr --output HDMI-0 --off
    #xrandr --output VGA-1 --off
    xrandr --output $external --off
}

#dual
$1
