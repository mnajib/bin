#!/bin/sh
# backup.sh
# vim:sw=2 ts=8:et sta:fdm=marker nowrap:
#
# Magnifix Sdn. Bhd. <http://www.magnifix.com.my/>
# Mohd Najib Bin Ibrahim <najib@magnifix.com.my> <mnajib@gmail.com>
#

#cp -v $1 $1-bak`date +%Y%m%d%H%M%S`.bak
if [ -f ${1} ]; then
  cp -vp "${1}" "${1}-bak`date +%Y%m%d%H%M%S`.bak"
elif [ -d ${1} ]; then
  cp -vpR "${1}" "${1}-bak`date +%Y%m%d%H%M%S`.bak"
else
  echo "error"
  exit 1
fi

exit
