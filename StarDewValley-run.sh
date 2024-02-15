#!/usr/bin/env bash

#USER=naim
OLDUSER="nurnasuha"
PATH1=~/.wine/drive_c
PATH2=${PATH1}/MyPrograms/Stardew.Valley.v1.5.4
PATH3=${PATH1}/users/${USER}/Application\ Data/StardewValley
PATH4=${PATH1}/users/${USER}/AppData/StardewValley
PATH5=${PATH2}/Stardew\ Valley

# Ready custom nested display
# Thinkpad X220 sakinah: 1366x768
#Xephyr -br -ac -noreset -screen 1080x768 :1 &
#Xephyr -br -ac -noreset -screen 1280x960 :1 &
case "$HOSTNAME" in
  "sakinah")
    xXephyr -br -ac -noreset -screen 1366x740 :1 &          # sakinah, thinkpad x220, 1336x768
    ;;
  "zahrah")
    Xephyr -br -ac -noreset -screen 1278x750 :1 &           # zahrah
    ;;
  "keira")
    #Xephyr -br -ac -noreset -screen 1440x872 :1 &          # keira, thinkpad t410, 1440x900
    Xephyr -br -ac -noreset -screen 1280x996 :1 &           # external monitor, 1280x1024
    ;;
  *)
    #Xephyr -br -ac -noreset -screen 1024x740 :1 &          # 1024x768
    #Xephyr -br -ac -noreset -screen 1024x768 :1 &          # 1024x768
    Xephyr -br -ac -noreset -screen 640x480 :1 &            #
    ;;
esac

# Reset StardewValley custom resolution
#cd ~/.wine/drive_c/users/nurnasuha/Application\ Data/StardewValley
#cat ~/.wine/drive_c/MyPrograms/Stardew.Valley.v1.5.4/config/startup_preferences > startup_preferences

#cd ~/.wine/drive_c/users/nurnasuha/AppData/StardewValley
#cat ~/.wine/drive_c/MyPrograms/Stardew.Valley.v1.5.4/config/startup_preferences > startup_preferences
#cat ~/.wine/drive_c/MyPrograms/Stardew.Valley.v1.5.4/config/startup_preferences > ~/.wine/drive_c/users/${USER}/AppData/Roaming/StardewValley/startup_preferences
cat ~/.wine/drive_c/MyPrograms/Stardew.Valley.v1.5.4/config/startup_preferences > ~/.wine/drive_c/users/${OLDUSER}/AppData/Roaming/StardewValley/startup_preferences

# Start the game
cd ~/.wine/drive_c/MyPrograms/Stardew.Valley.v1.5.4/Stardew\ Valley/
#DISPLAY=:1 wine ./Stardew\ Valley.exe
#DISPLAY=:1 wine ${PATH5}/Stardew\ Valley.exe
#cd ${PATH5}
DISPLAY=:1 wine ./Stardew\ Valley.exe
