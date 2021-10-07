#!/usr/bin/env bash

# set dual monitors
dual () {
    #xrandr --output VGA-0 --primary --left-of HDMI-0 --output HDMI-0 --auto
    xrandr --output LVDS-1 --mode 1280x800 --primary --auto --output VGA-1 --mode 1280x1024 --left-of LVDS-1 --auto
}

# set single monitor
single () {
    #xrandr --output HDMI-0 --off
    xrandr --output VGA-1 --off
}

dual
