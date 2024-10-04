#!/usr/bin/env bash

# Check the number of colors supported by the terminal
color_count=$(tput colors)

if [ "$color_count" -ge 256 ]; then
    echo "Your terminal supports $color_count colors."
    echo "Displaying all 256 colors:"

    # Loop through 256 colors and print them
    for i in {0..255}; do
        printf "\033[38;5;%dm%3d\033[0m " "$i" "$i"
        if (( (i + 1) % 16 == 0 )); then
            printf "\n"  # New line after every 16 colors
        fi
    done
else
    echo "Your terminal supports only $color_count colors."
    echo "Displaying basic colors:"

    # Display basic ANSI colors
    for i in {0..7}; do
        printf "\033[3${i}mColor %d\033[0m " "$i"
    done
    printf "\n"
fi

