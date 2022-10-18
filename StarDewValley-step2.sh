#!/usr/bin/env bash

PATH1=~/.wine/drive_c
PATH2=${PATH1}/MyPrograms/Stardew.Valley.v1.5.4
PATH3=${PATH1}/users/nurnasuha/Application\ Data/StardewValley
PATH4=${PATH1}/users/nurnasuha/AppData/StardewValley
PATH5=${PATH2}/Stardew\ Valley

# Ready custom nested display
# Thinkpad X220 sakinah: 1366x768
#Xephyr -br -ac -noreset -screen 1080x768 :1 &
#Xephyr -br -ac -noreset -screen 1280x960 :1 &
#Xephyr -br -ac -noreset -screen 1366x740 :1 &

# Reset StardewValley custom resolution
#cd ~/.wine/drive_c/users/nurnasuha/Application\ Data/StardewValley
#cat ~/.wine/drive_c/MyPrograms/Stardew.Valley.v1.5.4/config/startup_preferences > startup_preferences

#cd ~/.wine/drive_c/users/nurnasuha/AppData/StardewValley
#cat ~/.wine/drive_c/MyPrograms/Stardew.Valley.v1.5.4/config/startup_preferences > startup_preferences
#cat ${PATH2}/config/startup_preferences > ${PATH4}/startup_preferences

# Start the game
cd ~/.wine/drive_c/MyPrograms/Stardew.Valley.v1.5.4/Stardew\ Valley/
#DISPLAY=:1 wine ./Stardew\ Valley.exe
#DISPLAY=:1 wine ${PATH5}/Stardew\ Valley.exe
#cd ${PATH5}
DISPLAY=:1 wine ./Stardew\ Valley.exe
