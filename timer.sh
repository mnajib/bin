#!/bin/bash
# vim:ts=2 sw=2:et sta:

THISS="/home/najib/bin/timer.sh"
SOUND1="/home/najib/Downloads/alarmclock.mp3"

#VOLUME=30 # can increase the volume base on snooze count
#VOLUME=`env | egrep VOLUME sed 's/VOLUME=//'`
#VOLUME=`export | egrep VOLUME | sed "s/^.*VOLUME=\"//" | sed "s/\"$//"`
#VOLUME=`cat /tmp/VOL.tmp | egrep VOLUME | sed "s/^.*VOLUME=\"//" | sed "s/\"$//"`
VOLUME=`cat /tmp/VOL.tmp | tail -1`
#case $VOLUME in
#  ""|" ")
#    VOLUME=0
#    ;;
#esac
VOLUME=`echo "${VOLUME} + ${VOLUMESTEPUP}" | bc`
echo "$VOLUME" > /tmp/VOL.tmp

VOLUMESTEPUP=30 
#PLAYER="mpg123 ${SOUND1}"
PLAYER="/usr/bin/mplayer -ao pulse -volume ${VOLUME}"
SNOOZE="1 minutes" # minutes, days, ...

# creates temporary directories
tmpdir=$(mktemp -d)
tmpfile=$(mktemp -p $tmpdir)

# sorts by command line variables.  a is for alarm, t is for timer  This script calls itself for the actual alarm as well.
case "$1" in
	"a")   # invoke alarm set
    notify-send --icon=config-date "WAKE UP"  # visible alert
    ${PLAYER} "${SOUND1}" &  # play music/sound
    zenity --timeout 30 --question --text "Snooze?"  # snooze button
    case "$?" in
      "5")  # no response
        echo "${THISS} a" > $tmpfile   # creates a NEW task.  AT only creates one-time tasks.
        at -f $tmpfile now + 10 minutes
        ;;
      "0")  # Yes, snooze
        echo "${THISS} a" > $tmpfile
        at -f $tmpfile now + 10 minutes
        ;;
      "1")  # No, end it.
        killall mpg123
        ;;
    esac		
    ;;

	"t") 
    #echo "notify-send --icon=config-date \"WAKE UP\" &" > $tmpfile
    notify-send --icon=config-date "WAKE UP!" &
    #XXX: also need to reset pulseaudio volume (to maximum maybe) for device and application ...
    #pactl mplayer2 ...
    #export VOLUME=$VOLUME
    ${PLAYER} "${SOUND1}" &
    #zenity --timeout 10 --question --text "Snooze?"

    #case "$?" in
      #"5")
      #  echo "${THISS} t" > $tmpfile
      #  at -f $tmpfile now + ${SNOOZE}
      #  ;;
      #"1")
      #  echo "${THISS} t" > $tmpfile
      #  at -f $tmpfile now + ${SNOOZE}
      #  ;;
      #"0")
      #  echo "${THISS} t" > $tmpfile
      #  at -f $tmpfile now + ${SNOOZE}
      #  ;;
    #  *)
        #echo "export VOLUME=$VOLUME" >> $tmpfile
        #echo "${PLAYER} ${SOUND1} &" >> $tmpfile
        echo "${THISS} t" > $tmpfile
        at -f $tmpfile now + ${SNOOZE}
    #    ;;
    #esac		

    ;;

	"")
    echo -e "\E[0;32m(\E[0;37ma\E[0;32m)larm, (\E[0;37mt\E[0;32m)imer, or (\E[0;37mQ\E[0;32m)uit? "; tput sgr0
    read CHOICE
    case "$CHOICE" in
      "a")
        echo -e "\E[0;36mPlease input the time you want for the alarm (HH:MM)."; tput sgr0
        read time
        echo "export DISPLAY=:0.0;${THISS} a" > $tmpfile
        at -f $tmpfile $time
        ;;
      "t")	
        echo -e "\E[0;36mPlease input the time you want to timer for in minutes."; tput sgr0
        read number
        echo "export DISPLAY=:0.0;${THISS} t" > $tmpfile
        VOLUME=30
        #export VOLUME=$VOLUME
        echo "$VOLUME" > /tmp/VOL.tmp
        at -f $tmpfile now + $number minutes
        ;;	
      "*")
        echo "quitting."
        ;;			
    esac
    ;;
esac

rm $tmpfile
rmdir $tmpdir
