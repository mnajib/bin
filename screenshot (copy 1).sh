#!/bin/bash

scrot -c -d 5 '%Y-%m-%d_$wx$h_scrot.png' -e 'mv $f ~/Pictures/'
