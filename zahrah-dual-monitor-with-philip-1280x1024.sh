#!/usr/bin/env bash

#xrandr -q
#xrandr -s 1280x1024
#xrandr -dpi 96 -s 1280x1024
#xrandr --auto --output VGA-1 --mode 1280x1024 --left-of LVDS-1
#xrandr --auto --output VGA-1 --mode 1280x1024 --primary --left-of LVDS-1

#lxrandr
#grandr
#krandr
#arandr

#-------------------------------------------------------

# cvt is a newer than gtf?
cvt -r 1280 1024
  # 1280x1024 59.79 Hz (CVT 1.31M4-R) hsync: 63.02 kHz; pclk: 90.75 MHz
  # Modeline "1280x1024R"   90.75  1280 1328 1360 1440  1024 1027 1034 1054 +hsync -vsyn
#xrandr --newmode "1280x1024R"   90.75  1280 1328 1360 1440  1024 1027 1034 1054 +hsync -vsync
xrandr --newmode "1280x1024"   90.75  1280 1328 1360 1440  1024 1027 1034 1054 +hsync -vsync
#xrandr --addmode VGA-1 "1280x1024R"
xrandr --addmode VGA-1 "1280x1024"
#xrandr --output VGA-1 --mode "1280x1024R"
xrandr --output VGA-1 --mode "1280x1024"

#-------------------------------------------------------

#gtf 1280 1024 60
  # 1280x1024 @ 60.00 Hz (GTF) hsync: 63.60 kHz; pclk: 108.88 MHz
  # Modeline "1280x1024_60.00"  108.88  1280 1360 1496 1712  1024 1025 1028 1060  -HSync +Vsync
#xrandr --newmode "1280x1024_60.00"  108.88  1280 1360 1496 1712  1024 1025 1028 1060  -HSync +Vsync
#xrandr --addmode VGA-1 "1280x1024_60.00"
#xrandr --output VGA-1 --mode "1280x1024_60.00"

#-------------------------------------------------------

#touch $HOME/.xprofile
#chmod +x $HOME/.xprofile

#-------------------------------------------------------

xrandr \
	--output LVDS-1 --primary --mode 1024x768 --pos 1280x256 --rotate normal \
	--output VGA-1 --mode 1280x1024 --pos 0x0 --rotate normal \
	--output DP-1 --off \
	--output DP-2 --off \
	--output DP-3 --off

sleep 3
xmonad --restart
