#!/bin/bash

ifile=$1
ofile=${ifile}.mp3

# check if there is a file with same name with target output file name
#...

# convert
#ffmpeg -i input.flv -vn -acodec libmp3lame -ac 2 -ab 128k output.mp3
ffmpeg -i ${ifile} -vn -acodec libmp3lame -ac 2 -ab 128k ${ofile}

