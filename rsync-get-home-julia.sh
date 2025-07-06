#!/usr/bin/env bash

SRC='julia@keira:/home/julia/'
DES='/mnt/data/julia'

#rsync -az --exclude=.cache --exclude=.snapshots julia@keira:/home/julia/ /home/julia
#rsync -az --exclude=.cache --exclude=.snapshots $SRC $DES
#rsync -azP --exclude=.cache --exclude=.snapshots $SRC $DES
#rsync -vazP --progress --exclude=.cache --exclude=.snapshots $SRC $DES
sudo rsync -vazPAX --progress --exclude=.cache --exclude=.snapshots --delete $SRC $DES

#rm -Rf /home/julia/.cache /home/julia/.snapshots

