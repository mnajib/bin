#!/usr/bin/env bash
# vim: tabstop=4 shiftwidth=4 expandtab nowrap number

d=`xinput list | grep "ALPS DualPoint Stick" | awk '{for(i=1;i<=NF;i++){ tmp=match($i, /id=[0-9]/); if(tmp){print $i} } }' | awk --field-separator== '{ print $2 }'`
#14

de=`xinput list-props 14 | grep 'Coordinate Transformation Matrix' | awk --field-separator=: '{print $1}' | awk --field-separator=\( '{print $2}' | awk --field-separator=\) '{print $1}'`
#198

#xinput list-props 15 | grep -i coordinate
#	Coordinate Transformation Matrix (198):	0.500000, 0.000000, 0.000000, 0.000000, 0.500000, 0.000000, 0.000000, 0.000000, 1.000000

#xinput set-prop 15 198 0.7, 0.0, 0.0, 0.0, 0.7, 0.0, 0.0, 0.0, 1.0
#xinput set-prop 14 198 0.7, 0.0, 0.0, 0.0, 0.7, 0.0, 0.0, 0.0, 1.0
#xinput list-props 15 | grep -i coordinate
#	Coordinate Transformation Matrix (198):	0.500000, 0.000000, 0.000000, 0.000000, 0.500000, 0.000000, 0.000000, 0.000000, 1.000000

e=0.7
xinput set-prop $d $de $e, 0.0, 0.0, 0.0, $e, 0.0, 0.0, 0.0, 1.0

# Disable acceleration
#xset m 1 0
