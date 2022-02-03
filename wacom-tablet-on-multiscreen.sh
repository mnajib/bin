#!/usr/bin/env bash

# I have a dual screen setup and a Wacom tablet. As one screen is 4K UHD and the other FHD, this is too much screen estate for my shaky hand on the tiny Wacom tablet that I have (the tablet has 2540 lpi resolution, so this is not a restriction of the tablet, but the blame goes to me). Therefore, I want to restrict the tablet use to the FHD screen only in order to get a more calm pen usage.

# Use the command line tool xsetwacom: 
#
# get the 
# screen name via 
xrandr
#(e.g. eDP for the laptop screen) 
#
# and, get the 
# name of the Wacom tablet via 
xsetwacom --list. 
#Note that multiple entries are listed there for the same tablet: take care to use the one that ends with stylus. 
#
#In my case, I use
xsetwacom set "Wacom Intuos S Pen stylus" MapToOutput eDP

