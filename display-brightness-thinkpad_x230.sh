#!/usr/bin/env bash


#----------------------------------
# foreground brightness
#----------------------------------

# Get info
#xrandr --prop | grep " connected"
#xrandr --prop | grep -A10 " connected" | grep "Brightness"

# Set new brightness
#xrandr --output LVDS-1 --brightness 0.4
#xrandr --output LVDS-1 --brightness 0.6
xrandr --output LVDS-1 --brightness 0.7


#----------------------------------
# background brightness
#----------------------------------

# Set new background (backlight?) brightness
#echo 4437  > /sys/class/backlight/intel_backlight/brightness # default
#echo 1000  > /sys/class/backlight/intel_backlight/brightness # less bright
#echo 500  > /sys/class/backlight/intel_backlight/brightness # less bright
echo 100  > /sys/class/backlight/intel_backlight/brightness # less bright
#echo 80  > /sys/class/backlight/intel_backlight/brightness # less bright
