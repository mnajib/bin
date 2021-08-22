#!/run/current-system/sw/bin/env bash

M=5
t="$(( 60 * ${M} ))"

while true; do
	~/bin/listPlay.sh
	echo ""
	echo "--------------------"

	pgrep -a minetest | grep 'm' | awk '{print $1}' | tr '\n' ' ' | sed 's/$/\n/' | xargs kill
	pgrep -a bash | grep 'minetest' | awk '{print $1}' | tr '\n' ' ' | sed 's/$/\n/' | xargs kill

	pgrep -a bash | grep 'firefox' | awk '{print $1}' | tr '\n' ' ' | sed 's/$/\n/' | xargs kill
	pgrep -a firefox | grep 'fire' | awk '{print $1}' | tr '\n' ' ' | sed 's/$/\n/' | xargs kill
	
	echo "--------------------"
	~/bin/listPlay.sh

        #echo $t
	sleep $t
done