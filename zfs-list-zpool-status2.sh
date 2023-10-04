#!/usr/bin/env bash

POOLNAME=$1

function zpoolList {
  zpool list -v ${1}
}

function zpoolStatus {
  zpool status -v ${1}
}

function printZpoolList {
  echo "----------------------------------------------------------------------------------"
  echo " zpool list -v $1"
  echo "----------------------------------------------------------------------------------"
  echo ""
  zpoolList $1
}

function printZpoolStatus {
  #echo ""
  echo "----------------------------------------------------------------------------------"
  echo " zpool status -v $1"
  echo "----------------------------------------------------------------------------------"
  echo ""
  zpoolStatus $1
  #echo "----------------------------------------------------------------------------------"
}

function printZpoolIostat {
  local poolname=$1
  echo "----------------------------------------------------------------------------------"
  echo " zpool iostat $poolname"
  echo "----------------------------------------------------------------------------------"
  echo ""
  zpool iostat $poolname
}

function diskByID {
  ls -Filah /dev/disk/by-id | egrep -v '[0-9]$' | grep '[a-z]$' | grep ' ata-' | awk '{ print $12 "\t<--\t" $10 }' | sed 's/^..\/..\///' | sort -n | cat -n
}

function diskByUUID {
  ls -Filah /dev/disk/by-uuid/ | grep ' -> ' | awk '{ print $12 "\t<-\t" $10 }' | sort -t " " -k 3 | sed 's/^..\/..\///' | grep -v '^dm' | cat -n
}

function diskByPath {
  ls -Filah /dev/disk/by-path/ | grep ' pci-' | awk '{ print $12 "\t<--\t" $10  }' | sed 's/..\/..\///' | grep '^sd' | sort -n | cat -n
}

function printDiskByID {
  echo "----------------------------------------------------------------------------------"
  echo " Which disk is which? (by-id)"
  #echo "----------------------------------------------------------------------------------"
  diskByID
}

function printDiskByUUID {
  echo "----------------------------------------------------------------------------------"
  echo " Which disk is which? (by-uuid)"
  #echo "----------------------------------------------------------------------------------"
  diskByUUID
}

function printDiskByPath {
  echo "----------------------------------------------------------------------------------"
  echo " Which disk is which? (by-path)"
  #echo "----------------------------------------------------------------------------------"
  diskByPath
}

#printZpoolList najibzfspool1
#printZpoolStatus najibzfspool1
printZpoolList $POOLNAME
echo ""
printZpoolStatus $POOLNAME
echo ""
printZpoolIostat $POOLNAME
#printZpoolList dodol
echo ""
#printZpoolStatus dodol
#echo ""
#printZpoolStatus lempok
#printDiskByUUID
#printDiskByID
#printDiskByPath
#echo "----------------------------------------------------------------------------------"

#udevadm info /dev/sdj
#udevadm trigger
#udevadm info /dev/sdj
