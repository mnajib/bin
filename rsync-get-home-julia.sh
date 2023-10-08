#!/usr/env bash

rsync -az --exclude=.cache --exclude=.snapshots julia@keira:/home/julia/ /home/julia

#rm -Rf /home/julia/.cache /home/julia/.snapshots
