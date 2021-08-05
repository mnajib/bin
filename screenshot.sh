#!/run/current-system/sw/bin/env bash

#timestamp="$(date +%d.%m.%Y"_shot_"%H:%M:%S)"
targetbase="$HOME/Pictures/Screenshots"

mkdir -p $targetbase
[ -d $targetbase ] || exit 1

#import -window root -quality 98 $targetbase/$timestamp.png
scrot '%Y-%m-%d-%H%M%S-fullscreen.png' -b -e 'mv $f ~/Pictures/Screenshots/'
#scrot
