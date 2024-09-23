#!/usr/bin/env bash

#sudo dmidecode | awk '/^Memory Device$/ {main=1; print; next} main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {print}'

# With totaled memory installed
sudo dmidecode | awk '/^Memory Device$/ {main=1; print; next} main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {print; if ($3 == "GB") sum+=$2} END {print "Total Memory Installed:", sum, "GB"}'
