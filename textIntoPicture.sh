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
#convert ${inputf} -fill ${textcolor} -gravity North -pointsize 24 -annotate +0+100 ${text} ${outputf}
#convert ${inputf} -font ${font} -background ${background} -fill ${textcolor} -gravity North -pointsize 30 -annotate +0+100 ${text} ${outputf}

convert -verbose -density 150 ${inputf} -quality 100 -sharpen 0x1.0 -fill ${textcolor} -gravity North -pointsize 24 -annotate +0+100 ${text} ${outputf}
#convert -verbose -density 150 input.pdf -quality 100 -sharpen 0x1.0 -fill blue -gravity North -pointsize 24 -annotate +0+100 "Muhammad Na\'im Bin Mohd Najib,\n1 Beta, Matematik,\nRabu 2021-08-25." output.pdf

#convert           \
#   -verbose       \
#   -density 150   \
#   -trim          \
#    test.pdf      \
#   -quality 100   \
#   -flatten       \
#   -sharpen 0x1.0 \
