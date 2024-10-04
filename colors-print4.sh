#!/usr/bin/env bash

# Define an associative array for both standard and bright colors with their hex codes
#declare -A colors=(
#declare -A data2=(
data=(
    "0,Black,#000000,40"
    "1,Red,#FF0000,41"
    "2,Green,#00FF00,42"
    "3,Yellow,#FFFF00,43"
    "4,Blue,#0000FF,44"
    "5,Magenta,#FF00FF,45"
    "6,Cyan,#00FFFF,46"
    "7,White,#FFFFFF,47"
    "8,Bright_Black,#808080,100"  # Bright Black (Gray)
    "9,Bright_Red,#FF5555,101"    # Bright Red
    "10,Bright_Green,#55FF55,102"  # Bright Green
    "11,Bright_Yellow,#FFFF55,103"  # Bright Yellow
    "12,Bright_Blue,#5555FF,104"   # Bright Blue
    "13,Bright_Magenta,#FF55FF,105" # Bright Magenta
    "14,Bright_Cyan,#55FFFF,106"    # Bright Cyan
    "15,Bright_White,#FFFFFF,107"   # Bright White (same as standard white)
)

# Simulated 2D array data stored as strings
data2=(
    "0,a,aa"
    "1,b,bb"
    "2,c,cc"
    "3,d,dd"
    "4,e,ee"
    "5,f,ff"
    "6,g,gg"
    "7,h,hh"
)

# Function to print all data in tabular format
printData() {
    #echo "Index | Name1 | Name2"
    printf "%-14s | %-7s\n" "Color Name" "Code"
    echo "-----------------------"

    for n in {0..15}; do
        # Access the row using the index
        row="${data[$n]}"

        # Split the row into fields using IFS (Internal Field Separator)
        IFS=',' read -r index name1 name2 ansi <<< "$row"

        # Print the formatted output
        #printf "%-5s | %-6s | %-6s\n" "$index" "$name1" "$name2"
        #printf "$index, $name1, $name2\n"
        #printf "%-2s | %-14s | %-10s\n" "$index" "$name1" "$name2"
        #printf "%-14s | %-7s\n" "$name1" "$name2"

        #local fg=32
        #local bg=44
        local bg=${ansi}
        #printf "%-14s | %-7s \033[${fg};${bg}m \033[0m\n" "$name1" "$name2"
        printf "%-14s | %-7s \033[${bg}m \033[0m\n" "$name1" "$name2"

    done
}

# Function to print data for a specific index
printDataInIndex() {
    local index=$1

    # Check if the index is within bounds
    if (( index >= 0 && index < ${#data[@]} )); then
        # Access the row using the index
        row="${data[$index]}"

        # Split the row into fields using IFS (Internal Field Separator)
        IFS=',' read -r idx name1 name2 <<< "$row"

        # Print the formatted output for the specific index
        printf "%-5s | %-6s | %-6s\n" "$idx" "$name1" "$name2"
    else
        echo "Index out of bounds. Please provide a valid index (0 to $(( ${#data[@]} - 1 )))."
    fi
}

# Call the function to print all data initially
printData

# Example usage of printDataInIndex function:
#echo -e "\nPrinting data for index 3:"
#printDataInIndex 3  # Change this index to test different colors

