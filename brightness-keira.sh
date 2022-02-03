#!/usr/bin/env bash

# Usage: $0 VALUE
# where VALUE = [0-100]

#echo 80 > /sys/class/backlight/nv_backlight/brightness
echo $1 > /sys/class/backlight/nv_backlight/brightness
