#!/usr/bin/env bash

#nix-shell -p imagemagick

#convert Screenshot_2021-08-23\ Gerakan\ Badan\ Sihat\ Otak\ Cergas\ worksheet.png -gravity North -pointsize 30 -annotate +0+100 "Muhammad Na\'im Bin Mohd Najib, 1 Beta, Pendidikan Musik, Isnin 2021-08-23." temp1.png

#text="Muhammad Na\'im Bin Mohd Najib, 1 Beta, Pendidikan Musik, Isnin 2021-08-23."
text=$1
#font="helvetica"
#background="lightblue"
textcolor="blue"
#inputf="Screenshot_2021-08-23\ Gerakan\ Badan\ Sihat\ Otak\ Cergas\ worksheet.png"
#outputf="temp1.png"
inputf=$2
outputf="namestamped-${1}-${2}"

#convert ${inputf} -fill ${textcolor} -gravity North -pointsize 24 -annotate +0+100 ${text} ${outputf}
convert ${inputf} -fill ${textcolor} -gravity North -pointsize 24 -annotate +0+100 ${text} ${outputf}
#convert ${inputf} -font ${font} -background ${background} -fill ${textcolor} -gravity North -pointsize 30 -annotate +0+100 ${text} ${outputf}

