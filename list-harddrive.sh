while true; do lsblk -pfi | grep "^/" | grep -v zram | awk '{print $1}'; sleep 2; clear; done
