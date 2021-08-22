#!/run/current-system/sw/bin/env bash

#p=$1
#p="/mnt/sekolahdocdir"
p="/export/sekolahdocdir"

find ${p} -type d -print0 | xargs -0 sudo chmod 775
find ${p} -type f -print0 | xargs -0 sudo chmod 664
