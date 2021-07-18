

# Xrandr (Software Level)
# -----------------------------------------------------------------------------
# Get info
#xrandr --prop | grep " connected"
#xrandr --prop --verbose | grep -A10 " connected" | grep "Brightness"
# Set brightness
#xrandr --output HDMI-A-0 --brightness 0.4


# Xgamma (Software Level)
# -----------------------------------------------------------------------------
# xgamma
# xgamma -gamma 0.60


# Redshift (Software Level)
# -----------------------------------------------------------------------------
# redshif -b 0.60:0.70


# Xdotool (Hardware Level)
# -----------------------------------------------------------------------------
# xdotool key XF86MonBrightnessUp
# xdotool key XF86MonBrightnessDown


# Xbacklight (Hardware Level)
# -----------------------------------------------------------------------------
# xbacklight -get
# xbacklight -set 0.60


# Brightnessctl (Hardware Level)
# -----------------------------------------------------------------------------
# brightnessctl -l
# brightnessctl -d “0005:054C:09CC.0005:global” set 60%


