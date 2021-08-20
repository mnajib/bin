#!/run/current-system/sw/bin/env bash

# First clear/rest xrandr settings
xrandr -s0


xrandr --output LVDS-1 --scale 1.125x1.125 --panning 1440x900

# XXX: ?
#fbset



#---------------------
# DPI
#---------------------
xdpyinfo | grep dots
#   resolution:    97x96 dots per inch

xrandr | grep -w connected
# LVDS-1 connected primary 1440x900+0+0 (normal left inverted right x axis y axis) 303mm x 190mm panning 1440x900+0+0

#
# 1. Calculate lenght (in inches) of x-axis and y-axis of the display
#
#    lenght of x-axis = 303mm
#                     = 30.3 cm
#    Length of x-axis in inches = 30.3 cm / 2.54
#                               = 11.93 inches
#
#    lenght of y-axis = 190 mm
#                     = 19.0 cm
#    Length of y-axis in inches = 19.0 cm / 2.54
#                               = 7.48 inches
#
# 2. Calculate the target dots amount (based on resolution) by the size in inches
#
#    dpi for x-axis = 1440 / 11.93
#                   ~ 120 dpi
#
#    dpi for y-axis = 900 / 7.48
#                   ~ 120 dpi
#
# 3. Set new dpi
#
#    xrandr --dpi 120
#    or
#    xrandr --dpi 120x120
#

xrandr --dpi 120


# nix-shell -p python3Minimal
#echo 'print ( (((1440 ** 2)+(900 ** 2) ) ** (0.5) ) / 14 )' | python3
#121.29404312644205 # ~ 121 DPI ~ 120 DPI ??
#
#echo "Xft.dpi: 120" >> ~/.Xresources
#xrdb -merge ~/.Xresources
#
#echo "xrandr --dpi 120" >> ~/.xsessionrc
#xfce4-session-logout --logout
#



