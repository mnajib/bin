#!/usr/bin/env bash

while true; do xrandr | grep -i connected | grep -i -v disconnected; echo "------"; sleep 1; done
