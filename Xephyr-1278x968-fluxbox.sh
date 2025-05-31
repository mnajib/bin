#!/usr/bin/env bash
Xephyr :1 -screen 1278x968 &
sleep 1
DISPLAY=:1 fluxbox &
DISPLAY=:1 terminology &
