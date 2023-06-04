#!/usr/bin/env bash

#thinkPadW=1600
#thinkPadH=900
#thinkPadF=60

thinkVisionW=1280
thinkVisionH=1024
thinkVisionF=60       #75

Dell_P1913S_W=1280
Dell_P1913S_H=1024
Dell_P1913S_F=60

#lxrandr
#grandr
#krandr
#arandr

#-------------------------------------------------------

# Usage:
#   generateModelineUsingCVT $thinkVisionW $thinkVisionH $thinkVisionF
# will return:
#   ...
generateModelineUsingCVT () {
  #cvt 1280 1024
  #cvt -r 1280 1024
  #cvt 1280 1024 75
  #cvt $1 $2 $3
  echo $(cvt $1 $2 $3 | grep '^Modeline' | sed 's/^Modeline //')
}

generateModelineUsingGTF () {
  #gtf 1280 1024 60
  #gtf 1280 1024 75
  #gtf $1 $2 $3
  echo $(gtf $1 $2 $3 | grep 'Modeline' | sed  's/^.*Modeline //')
}

getMonitorName () {
  displayName=$(xrandr | grep " connected " | awk '{ print $1}')
}

xrandr.get ()
{
  #declare -a Res=($(xrandr |grep " connected"));
  #local -n Res=($(xrandr |grep " connected")) || return 1
  local Res=($(xrandr |grep " connected")) || return 1

  echo ${Res[0]};
  echo ${Res[2]%%+*}
}

# Usage
#   addModeline $modeline
addModeline () {
  #xrandr --newmode "1280x1024R"   90.75  1280 1328 1360 1440  1024 1027 1034 1054 +hsync -vsync
  xrandr --newmode $1
  #xrandr --newmode $1 || return 1

  #xrandr --addmode VGA-1 "1280x1024R"
  xrandr --addmode VGA-1 "$(echo "$1" | awk '{print $1}')"
  #xrandr --addmode VGA-1 "$(echo "$1" | awk '{print $1}')" || return 1

  #echo "$1" | awk '{print "\"" $1 "\""}'
  echo "$1" | awk '{print $1}'
}

# Usage:
#   applyModeline "1280x1024_60.00"
applyModeline () {
  #xrandr --output VGA-1 --mode "1280x1024R"
  #xrandr --output DisplayPort-0 --off --output HDMI-0 --off --output DVI-0 --primary --mode 1280x1024_75.00 --pos 0x0 --rotate normal
  #xrandr --output VGA-1 --mode $1
  xrandr --output LVDS-1 --primary --mode 1600x900 --pos 1280x130 --rotate normal \
         --output VGA-1 --mode $1  --pos 0x0 --rotate normal \
         --output HDMI-1 --off \
         --output DP-1 --off \
         --output HDMI-2 --off \
         --output DP-2 --off \
         --output DP-3 --off
}

#XXX: just lazy
testingDirectCommand () {
  # For delldesktop dual monitor with ThinkVision and PanasonicTV
  xrandr --output VGA-1 --primary --mode 1280x1024 --pos 640x1080 --rotate normal --output HDMI-1 --mode 1920x1080i --pos 0x0 --rotate normal --output DP-1 --off
}

main () {
  #xrandr.get
  #generateModelineUsingCVT $thinkVisionW $thinkVisionH $thinkVisionF
  #generateModelineUsingGTF $thinkVisionW $thinkVisionH $thinkVisionF

  #addModeline "$(generateModelineUsingCVT $thinkVisionW $thinkVisionH $thinkVisionF)"
  #addModeline "$(generateModelineUsingGTF $thinkVisionW $thinkVisionH $thinkVisionF)"

  #applyModeline
  applyModeline "$(addModeline "$(generateModelineUsingCVT $thinkVisionW $thinkVisionH $thinkVisionF)" )"
}


#generateModelineUsingCVT $thinkVisionW $thinkVisionH $thinkVisionF
#main

testingDirectCommand

# cvt is a newer than gtf?
#cvt -r 1280 1024
  # 1280x1024 59.79 Hz (CVT 1.31M4-R) hsync: 63.02 kHz; pclk: 90.75 MHz
  # Modeline "1280x1024R"   90.75  1280 1328 1360 1440  1024 1027 1034 1054 +hsync -vsyn
#--> generateModelineUsingCVT $thinkVisionW $thinkVisionH $thinkVisionF
#xrandr --newmode "1280x1024R"   90.75  1280 1328 1360 1440  1024 1027 1034 1054 +hsync -vsync
#xrandr --addmode VGA-1 "1280x1024R"
#xrandr --output VGA-1 --mode "1280x1024R"


#gtf 1280 1024 75
#--> generateModelineUsingGTF $thinkVisionW $thinkVisionH $thinkVisionF
#--> xrandr --newmode "1280x1024_75.00"  138.54  1280 1368 1504 1728  1024 1025 1028 1069  -HSync +Vsync
#--> xrandr -q
#xrandr --addmode VGA-1 "1280x1024_75.00"
#--> xrandr --addmode DVI-0 "1280x1024_75.00"
#xrandr --output VGA-1 --mode "1280x1024_75.00"
#xrandr --output DVI-0 --mode "1280x1024_75.00"
#-->xrandr --output DisplayPort-0 --off --output HDMI-0 --off --output DVI-0 --primary --mode 1280x1024_75.00 --pos 0x0 --rotate normal


#-------------------------------------------------------

# test scale and pan; but blur
#xrandr --output VGA-1 --mode "1280x1024_75.00" --scale 1.125 --panning 1440x1152

# reset panning
#xrandr --output VGA-1 --mode "1280x1024_75.00" --scale 1 --panning 1280x1024

#-------------------------------------------------------

#touch $HOME/.xprofile
#chmod +x $HOME/.xprofile

#-------------------------------------------------------

#xrandr \
#	--output LVDS-1 --primary --mode 1024x768 --pos 1280x256 --rotate normal \
#	--output VGA-1 --mode 1280x1024R --pos 0x0 --rotate normal \
#	--output DP-1 --off \
#	--output DP-2 --off \
#	--output DP-3 --off
#sleep 3
#xmonad --restart
#
# OR
#
# use arandr


#-------------------------------------------------------

#xdpyinfo | grep -B 2 resolution
