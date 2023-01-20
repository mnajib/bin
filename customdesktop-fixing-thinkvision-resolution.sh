#!/usr/bin/env bash

# Ada:
#   1024x768 60
# Patut ada:
#   1280x1024 60

# 1280 / 1024 = 1.25
# 1024 / 768 = 1.33333333333333333333

# Test used the setting:
#   xrandr --output VGA-1 --mode 1024x768 --panning 1280x1024 --scale 1.25x1.33333333333333333333
# It works, but all display blurry, not really useable.
# Reset back to default:
#   xrandr --output VGA-1 --mode 1024x768 --panning 0x0 --scale 1x1
