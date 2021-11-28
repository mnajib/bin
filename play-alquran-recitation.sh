#!/usr/bin/env bash

path="/home/DATA/_agama.islam.Al-Quran/_av/hudhaifi - bacaan mudah ikut"

find ${path} | sort -n | xargs -0 -L1 -d '\n' mpv -
