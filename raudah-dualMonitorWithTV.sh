#!/usr/bin/env bash

# raudah dual-monitor with Panasonic TV

cvt -r 1366 768
xrandr --newmode "1368x768_60.00"  85.86  1368 1440 1584 1800  768 769 772 795  -HSync +Vsync
xrandr --addmode VGA-1 "1368x768_60.00"
xrandr --output VGA-1 --mode "1368x768_60.00"

# copied from arandr
#xrandr \
#	--output LVDS-1 --mode 1280x800 --pos 44x768 --rotate normal \
#	--output VGA-1 --primary --mode 1368x768_60.00 --pos 0x0 --rotate normal \
#	--output HDMI-1 --off \
#	--output DP-1 --off \
#	--output HDMI-2 --off \
#	--output DP-2 --off \
#	--output DP-3 --off
