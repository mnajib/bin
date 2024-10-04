#!/usr/bin/env bash

# Function to print ANSI colors side by side
print_colors() {
    # Define the number of columns
    local columns=1
    local count=0

    # Print header
    printf "\n"
    printf "%-30s %-30s\n" "Standard Foreground Colors" "Bright Foreground Colors"
    echo "-----------------------------------------------------------"

    fg1=30 # black foreground
    fg2=90 # bright-black foreground
    bg1=40 # black background
    bg2=47 # white background

    # Loop through standard colors (0-7)
    for f in {0..7}; do
        # Column-1: Print standard foreground colors, with black background 
        printf "\033[${fg1};${bg1}m%-30s\033[0m" "Fg1: ${fg1}"  # Standard foreground color

        # Column-2: Print bright foreground colors, with black background
        printf "\033[${fg2};${bg1}m%-30s\033[0m" "Fg2: ${fg2}"  # Bright foreground color

        # Column-1: Print standard foreground colors, with white background 
        printf "\033[${fg1};${bg2}m%-30s\033[0m" "Fg1: ${fg1}"  # Standard foreground color

        # Column-2: Print bright foreground colors, with white background
        printf "\033[${fg2};${bg2}m%-30s\033[0m" "Fg2: ${fg2}"  # Bright foreground color

        ((fg1++))
        ((fg2++))
        ((count++))

        # Check if we reached the column limit
        if (( count % columns == 0 )); then
            printf "\n"  # New line after reaching the column limit
        fi
    done

    #--------------------------------------------------------------------------

    count=0  # Reset count for background colors

    # Print header for background colors
    printf "\n"
    printf "%-30s %-30s\n" "Standard Backgrounds" "Bright Backgrounds"
    echo "-----------------------------------------------------------"

    fg1=37  # white foreground
    fg2=30  # black foreground
    bg1=40  # black background
    bg2=100 # bright-black background

    # Loop through standard colors (0-7)
    for f in {0..7}; do
        # Column-1: Print standard color
        printf "\033[${fg1};${bg1}m%-30s\033[0m" "Bg1: ${bg1}"  # Standard foreground color

        # Column-2: Print bright color
        printf "\033[${fg1};${bg2}m%-30s\033[0m" "Bg2: ${bg2}"  # Bright foreground color

        # Column-1: Print standard color
        printf "\033[${fg2};${bg1}m%-30s\033[0m" "Bg1: ${bg1}"  # Standard foreground color

        # Column-2: Print bright color
        printf "\033[${fg2};${bg2}m%-30s\033[0m" "Bg2: ${bg2}"  # Bright foreground color

        ((bg1++))
        ((bg2++))
        ((count++))

        # Check if we reached the column limit
        if (( count % columns == 0 )); then
            printf "\n"  # New line after reaching the column limit
        fi
    done

    # New line at the end of output
    printf "\n"
}

# Call the function to print colors
print_colors

