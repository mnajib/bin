#!/usr/bin/env bash

path=$1
text=$2

#grep --recursive --line-number "$1" -e "$2"
grep -rn "$1" -e "$2"
#grep -Rn "$1" -e "$2"
