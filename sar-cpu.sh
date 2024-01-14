#!/bin/ksh

#$1 - sar file sar##
sarFile=$1

lineTotal=`cat $1 | wc -l`
lineStartCPU=`grep -n CPU $1 | head -1| awk '{print $1}' | awk -F: '{print $1}'`
lineEndCPU=`grep -n "^Average" $1 | head -1| awk '{print $1}' | awk -F: '{print $1}'`

#printStart=$( echo "$lineTotal - $lineStartCPU" | bc -l )
printStart=$( echo "$lineTotal - $lineStartCPU + 1" | bc -l )
printEnd=$( echo "$lineEndCPU -1 " | bc -l )

header=`tail -$printStart $1 | head -1`
#tail -$printStart $1 | grep -v "^$"
#tail -$printStart $1 | head -$lineEndCPU | grep -v "^$" 

print "$header"
tail -$printStart $1 | head -$printEnd | grep -v "^$" | grep -v "CPU"

# TODO
# ...
#print "CPU Usage Average: $average"
#print "CPU Usage Peak: $peak"
#print "CPU Usage Peak Period: $peak period"


