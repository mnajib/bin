#!/usr/bin/env bash

# Define an associative array for both standard and bright colors with their hex codes
#declare -A colors=(
#declare -A data2=(
data=(
    # Standard colors ---------------------------------------------------------
    "0,Black,#000000,30,40" # Standard black as black
    "1,Red,#FF0000,31,41" # Bright red as red
    "2,Green,#00FF00,32,42" # Bright green as green
    "3,Yellow,#FFFF00,33,43" # Bright yellow as yellow
    "4,Blue,#0000FF,34,44" # Bright blue as blue
    "5,Magenta,#FF00FF,35,45" # Bright magenta as magenta
    "6,Cyan,#00FFFF,36,46" # Bright cyan as cyan
    #"7,White,#FFFFFF,37,47" # as White
    "7,White,#D3D3D3,37,47" # Light gray (instead of pure white) as White
    # Bright colors -----------------------------------------------------------
    #"8,Bright_Black,#808080,90,100"  # Bright Black
    "8,Bright_Black,#555753,90,100"  # Dark gray (for contrast) as Bright Black
    #"9,Bright_Red,#FF5555,91,101"    # Bright Red
    "9,Bright_Red,#EF2929,91,101"    # Lighter red (for brightness) as Bright Red
    #"10,Bright_Green,#55FF55,92,102"  # as Bright Green
    "10,Bright_Green,#8AE234,92,102"  # Lighter green (for brightness) as Bright Green
    #"11,Bright_Yellow,#FFFF55,93,103"  # as Bright Yellow
    "11,Bright_Yellow,#FCE94F,93,103"  # Lighter yellow (for brightness) as Bright Yellow
    #"12,Bright_Blue,#5555FF,94,104"   # as Bright Blue
    "12,Bright_Blue,#32AFFF,94,104"   # Lighter blue (for brightness) as Bright Blue
    #"13,Bright_Magenta,#FF55FF,95,105" # as Bright Magenta
    "13,Bright_Magenta,#AD7FA8,95,105" # Lighter magenta (for brightness) as Bright Magenta
    #"14,Bright_Cyan,#55FFFF,96,106"    # as Bright Cyan
    "14,Bright_Cyan,#34E2E2,96,106"    # Lighter cyan (for brightness) as Bright Cyan
    "15,Bright_White,#FFFFFF,97,107"   # Pure white (kept as is) as Bright White (same as standard white)
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
    printf "%-35s\n" "----------------------------------------------"
    printf "%-14s | %-9s | %-7s | %-7s\n" "Color Name" "Hex" "ANSI Fg" "ANSI Bg"
    printf "%-14s | %-9s | %-7s | %-7s\n" "--------------" "---------" "-------" "-------"

    for n in {0..15}; do
        # Access the row using the index
        row="${data[$n]}"

        # Split the row into fields using IFS (Internal Field Separator)
        IFS=',' read -r index name hex ansifg ansibg <<< "$row"

        c="\033[${ansibg}m \033[0m"
        printf "%-14s | %-9s | %-7s | %-5s ${c}\n" "$name" "$hex" "$ansifg" "$ansibg"

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

