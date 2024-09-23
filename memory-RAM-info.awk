
####!/usr/bin/env awk -f

# Author: Muhammad Najib Bin Ibrahim (NajibMalaysia)
# E-main: mnajib@gmail.com
# License: MIT License

# This script analyzes dmidecode output to determine memory card sizes and counts.
#
# Example usage:
#   #sudo dmidecode | awk -f memory_info.awk
#   ~/bin/memory_info.awk < dmidecode_output
#
# chmod +x memory_info.awk

BEGIN {
    print "------------------------------------------------"
    print " Get data from dmidecode:"
    print "------------------------------------------------"

    # Initialize variables
    main = 0
}

/^Memory Device$/ {
    # Process lines starting with "Memory Device"
    main = 1
    print
    next
}

main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {
    # Process lines containing memory information
    print
    if ($3 == "GB") {
        size[$2]++  # Increment size count
        count[$2]++  # Increment card count
        sum+=$2 # Totol memery installed
    }
}

END {
    # Print summary
    print "------------------------------------------------"
    print " Summary:"
    print "------------------------------------------------"
    for (element in size) {
        #print "Memory Card Size:", element, "GB, Number of Cards:", count[element]
        #print "Number of ", element, "GB Cards: ", count[element]
        print count[element], " x ", element, "GB Memory Card"
    }
    print "Total Memory Installed:", sum, "GB"
}


