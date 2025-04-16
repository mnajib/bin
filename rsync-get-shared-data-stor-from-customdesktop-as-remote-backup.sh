#!/usr/bin/env bash

SRC='root@customdesktop.localdomain:/mnt/data/'
DES='/MyTank/backups/offsite/customdesktop/mnt/data'

#
# Not really tested, only run once, and failed
#

#rsync -az --exclude=.cache --exclude=.snapshots julia@keira:/home/julia/ /home/julia
#rsync -az --exclude=.cache --exclude=.snapshots $SRC $DES
#rsync -azP --exclude=.cache --exclude=.snapshots $SRC $DES
rsync -vazP --progress --exclude=.cache --exclude=.snapshots $SRC $DES

#rm -Rf /home/julia/.cache /home/julia/.snapshots
