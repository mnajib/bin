#!/run/current-system/sw/bin/env bash

LC_ALL=C lspci -v | grep -EA10 "3D|VGA" | grep 'prefetchable'

#echo "--------------------"
#sudo dmesg | grep drm

#echo "--------------------"
#sudo dmesg | grem VRAM

echo "--------------------"
glxinfo | egrep -i 'device|memory'
