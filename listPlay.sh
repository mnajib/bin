#!/run/current-system/sw/bin/env bash

printT(){
    local f1="\n---((( "
    local f2=" )))---"
    #echo -e "${f1}${1}${f2}"
    echo -n ""
}

#ps auxwww | egrep -i "zikir|xmobar|solat|trayer|LED|pasystray|volumeicon"

printT "firefox"
pgrep -a firefox
pgrep -a bash | grep 'firefox'
killall -9 firefox

printT "minetest"
pgrep -a bash | grep 'minetest'
pgrep -a minetest
killall -9 minetest

#printT "trayer"
#pgrep -a trayer | grep 'trayer --edge top --align right'

#printT "zikir marque"
#pgrep -a bash | grep '/zikir'

#printT "pasystray"
#pgrep -a pasystray

#printT "volumeicon"
#pgrep -a volumeicon

#printT "nm-applet"
#pgrep -a nm-applet
