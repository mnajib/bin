#!/usr/bin/env bash

#xinput list
#xinput list-props 15 | grep -i coordinate
#	Coordinate Transformation Matrix (198):	0.500000, 0.000000, 0.000000, 0.000000, 0.500000, 0.000000, 0.000000, 0.000000, 1.000000

xinput set-prop 15 198 0.7, 0.0, 0.0, 0.0, 0.7, 0.0, 0.0, 0.0, 1.0
#xinput list-props 15 | grep -i coordinate
#	Coordinate Transformation Matrix (198):	0.500000, 0.000000, 0.000000, 0.000000, 0.500000, 0.000000, 0.000000, 0.000000, 1.000000

# Disable acceleration
#xset m 1 0
