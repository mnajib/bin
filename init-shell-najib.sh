#!/usr/bin/env bash

umask 0002
export DISPLAY=:0
export EDITOR=vis

echo "umask=`umask`"
echo "DISPLAY=${DISPLAY}"
echo "EDITOR=${EDITOR}"
