#!/usr/bin/env bash

# Refer also config in /etc/sudoers file

#sudo echo "100" > /sys/devices/platform/i8042/serio1/serio2/sensitivity
echo "130" > /sys/devices/platform/i8042/serio1/serio2/sensitivity
