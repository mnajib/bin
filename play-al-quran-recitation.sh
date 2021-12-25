#!/usr/bin/env bash

#path="/home/DATA/_agama.islam.Al-Quran/_av/hudhaifi - bacaan mudah ikut"

#find "${path}" | sort -n | grep -i -E "\.mp3" | xargs -0 -L1 -d '\n' mpv -
find "${1}" | sort -n | grep -i -E "\.mp3" | xargs -0 -L1 -d '\n' mpv -
#mpv --loop-playlist
