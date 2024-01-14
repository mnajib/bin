#!/bin/bash
#
# Author: Muhammaad Najib Bin Ibrahim <najib@vn.my> <mnajib@gmail.com>
#
# Usage:
#     fscada-sim.sh | grep '.22835.5.1.1'
#     watch 'fscada-sim.sh | grep "22835.5.1.1"'
#     bin/fscada-sim.sh | awk -F " " '{print $5}' | awk -F "," '{print $2 " --> " $3}
#     while true; do bin/fscada-sim.sh | grep 22835.2.1.2; sleep 1; done
#     while true; do bin/fscada-sim.sh | grep '22835.2.1.2\|22835.2.3.2'; sleep 1; done
#     while true; do bin/fscada-sim.sh | grep -E '22835.2.1.2|22835.2.3.2'; echo '-------------------'; sleep 1; done
#     while true; do bin/fscada-sim.sh | grep -E '22835.2.'| head -8; echo '-------------------'; sleep 1; clear; done
#     while true; do bin/fscada-sim.sh | grep -e '22835.2.1.2' -e '22835.2.3.2'; sleep 1; done
#

#while true; do
    #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 10.1.100.100 .1.3.6.1.4.1.22835
    snmpbulkwalk -v2c -Cn0 -Cr500 -c public 10.1.100.100 .1.3.6.1.4.1.22835 | awk -F " " '{print $5}' | awk -F "," '{print $2 " --> " $3}'| sed 's/\"$//g'
    #snmpbulkget -v2c -c public 10.1.100.100 1.3.6.1.4.1.22835
#    sleep 1
#done

