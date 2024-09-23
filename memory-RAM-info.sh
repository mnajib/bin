#!/usr/bin/env bash

# Author: Muhammad Najib Bin Ibrahim (NajibMalaysia)
# E-mail: mnajib@gmail.com
# License: MIT License

#sudo dmidecode | awk '/^Memory Device$/ {main=1; print; next} main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {print}'

# With totaled memory installed
#sudo dmidecode | awk '/^Memory Device$/ {main=1; print; next} main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {print; if ($3 == "GB") sum+=$2} END {print "Total Memory Installed:", sum, "GB"}'

#sudo dmidecode | awk '/^Memory Device$/ {main=1; print; next} main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {print; if ($3 == "GB") {size[$2]++; count[$2]++}} END {print "Total Memory Installed:", sum, "GB"; for (size in count) print "Memory Card Size:", size, "GB, Number of Cards:", count[size]}'
#sudo dmidecode | awk '/^Memory Device$/ {main=1; print; next} main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {print; if ($3 == "GB") {size[$2]++; count[$2]++; sum+=$2}} END {print "Total Memory Installed:", sum, "GB"; for (size in count) print "Memory Card Size:", size, "GB, Number of Cards:", count[size]}'
#sudo dmidecode | awk '/^Memory Device$/ {main=1; print; next} main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {print; if ($3 == "GB") sum+=$2} END {print "Total Memory Installed:", sum, "GB"}'

# including a summary of the total installed memory and a list of matching memory cards with their sizes and counts.
##sudo dmidecode | awk '/^Memory Device$/ {main=1; print; next} main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {print; if ($3 == "GB") {size[$2]++; count[$2]++}} END {print "Total Memory Installed:", sum, "GB"; for (element in size) print "Memory Card Size:", element, "GB, Number of Cards:", count[element]}'

# Run dmidecode and pipe the output to the awk script
sudo dmidecode | awk -f ~/bin/memory-RAM-info.awk
