#!/usr/bin/env bash

echo
zpool list -o name,size,alloc,free,freeing,dedup,health
echo
zpool list -v

echo
zfs list -o name,avail,used,usedsnap,usedds,usedrefreserv,usedchild,compression,volsize -r
echo
zfs list -o name,avail,used,compression,quota,reserv,refreserv,volsize
echo
zfs list -o avail,used,name
echo
zfs list
