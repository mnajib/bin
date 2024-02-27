#!/usr/bin/env bash

#----------------------------------
# Help
#----------------------------------
Help()
{
    # Display Help
    echo "Change foreground and background screen lingt brightness."
    echo
    echo "Syntax: $0 [-fg <FGBRIGHTNESS>] [-bg <BGBRIGHTNESS>]"
    echo
    echo "FGBRIGHTNESS: 0.0 to 1.0"
    echo
    echo "BGBRIGHTNESS: 0 to 4437"
    echo
}


#----------------------------------
# foreground brightness
# XXX: software level ?
#----------------------------------

# Get info
#xrandr --prop | grep " connected"
#xrandr --prop | grep -A10 " connected" | grep "Brightness"

#
# Set new brightness
# xrandr --output LVDS-1 --brightness 0.4
# xrandr --output LVDS-1 --brightness 0.6
# xrandr --output LVDS-1 --brightness 0.7
#
setFgBrightness()
{
    local $OUTPUT=$1
    local $FGBRIGHTNESS=$2

    xrandr --output $OUTPUT --brightness $FGBRIGHTNESS
}

increaseFgBrightness()
{
    # increase by 0.1
    echo "..."
}

decreaseFgBrightness()
{
    # decrease by 0.1
    echo "..."
}

toggleFgBrightness()
{
    local $OUTPUT=$1
    local $BRIGHTNESS1=1.0
    local $BRIGHTNESS2=0.7

    #if brightness >= 1.0
      # change brightness to 0.7
    #else if brightness <= 0.7
        # change brightness to 1.0
    #else
        # change brightness to 1.0
}

#----------------------------------
# background brightness
# XXX: hardware level ?
#----------------------------------

# Set new background (backlight?) brightness
#echo 4437  > /sys/class/backlight/intel_backlight/brightness # default
#
# This look nice on Thinkpad X220 sakinah
#sakinah)
#echo 1500  > /sys/class/backlight/intel_backlight/brightness # less bright
#
#echo 500  > /sys/class/backlight/intel_backlight/brightness # less bright
#
# This is suit Thinkpad X230?
echo 100  > /sys/class/backlight/intel_backlight/brightness # less bright
#
#echo 80  > /sys/class/backlight/intel_backlight/brightness # less bright

# nix-env -iA nixos.brightnessctl
# brightnessctl -d "intel_backlight" set 50%


#----------------------------------
# Main
#----------------------------------
#getFgBrightnessInfo
#getBgBrightnessInfo
setFgBrightness LVDS-1 0.7
#setBgBrightness intel_backlight 100

