#!/run/current-system/sw/bin/env bash

#p=$1
#p="/mnt/sekolahdocdir"
p="/export/sekolahdocdir"
dirs=( "03 Naqib" "04 Nur Nasuha" "05 Na'im" )

#echo ${dirs[1]}
#echo ${dirs[*]}
#echo ${#dirs[@]}

c=0
while [ $c -le ${#dirs[@]} ]
do
	echo "chmod directories ${p}/${dirs[${c}]} ..."
	#find "${p}/${dirs[${c}]}" -type d -print0 | xargs -0 sudo chmod 775
	find "${p}/${dirs[${c}]}" -type d -print0 | xargs -0 sudo chmod a+rwx

	echo "chmod files ${p}/${dirs[${c}]} ..."
	#find "${p}/${dirs[${c}]}" -type f -print0 | xargs -0 sudo chmod 664
	find "${p}/${dirs[${c}]}" -type f -print0 | xargs -0 sudo chmod a+rw

	((c++))
done

sync
sync
