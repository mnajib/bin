#!/usr/bin/env bash

#
# Usage:
#   init-second-monitor1280x1024-forKeira.sh dual
#   init-second-monitor1280x1024-forKeira.sh single
#

export DISPLAY=:0
#export XAUTHORITY=/home/juliani/.Xauthority

internal=LVDS-1 # right
external=VGA-1  # left

#dmode="$(cat /sys/class/drm/card0-VGA-1/status)"

# set dual monitors
dual () {
    #xrandr --output VGA-0 --primary --left-of HDMI-0 --output HDMI-0 --auto
    #xrandr --output LVDS-1 --mode 1280x800 --primary --auto --output VGA-1 --mode 1280x1024 --left-of LVDS-1 --auto
    #xrandr --output $internal --mode 1280x800 --primary --auto --output $external --mode 1280x1024 --left-of $internal --auto
    #xrandr --output $internal --mode 1280x800 --primary --pos 1280x224 --output $external --mode 1280x1024 --pos 0x0
    #xrandr --output $internal --mode 1280x800 --primary --pos 1280x480 --output $external --mode 1280x1024 --pos 0x0
    xrandr --output $internal --mode 1440x900 --primary --pos 1440x480 --output $external --mode 1280x1024 --pos 0x0
}

# set single monitor
single () {
    #xrandr --output HDMI-0 --off
    #xrandr --output VGA-1 --off
    xrandr --output $external --off
}

#dual
