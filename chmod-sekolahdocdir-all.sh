#!/run/current-system/sw/bin/env bash

#p=$1
#p="/mnt/sekolahdocdir"
p="/export/sekolahdocdir"
dirs=( "02 Juliani" "03 Naqib" "04 Nur Nasuha" "05 Na'im" )

#echo ${dirs[1]}
#echo ${dirs[*]}
#echo ${#dirs[@]}

c=0
while [ $c -le ${#dirs[@]} ]
do
	# chmod directories
	find "${p}/${dirs[${counter}]}" -type d -print0 | xargs -0 sudo chmod -v 775

	# chmod files
	find "${p}/${dirs[${counter}]}" -type f -print0 | xargs -0 sudo chmod -v 664

    # chown
    #...

	((c++))
done

sync
sync
