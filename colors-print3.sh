#!/usr/bin/env bash

# Function to print ANSI colors side by side
print_colors() {
    local w=15 # 30
    local w2=$((15 * 2))

    # Define the number of columns
    local columns=1
    local count=0

    # Print header
    #printf "%-30s%-30s  %-30s%-30s\n" "Black Background Color" "White Background Color" "Black Background Color" "White Background Color"
    printf "%-30s%-30s  %-30s%-30s\n" "-Black Background Color------" "-White Background Color------" "-Black Background Color------" "-White Background Color-------"

    local fg1=30 # black foreground
    local fg2=90 # bright-black foreground
    local bg1=40 # black background
    local bg2=47 # white background

    # Loop through standard colors (0-7)
    for f in {0..7}; do

        # Column-1: Print standard foreground colors, with black background 
        printf "\033[${fg1};${bg1}m%-${w}s\033[0m" "Fg1: ${fg1}"  # Standard foreground color

        # Column-2: Print bright foreground colors, with black background
        printf "\033[${fg2};${bg1}m%-${w}s\033[0m" "Fg2: ${fg2}"  # Bright foreground color

        # Column-1: Print standard foreground colors, with white background 
        printf "\033[${fg1};${bg2}m%-${w}s\033[0m" "Fg1: ${fg1}"  # Standard foreground color

        # Column-2: Print bright foreground colors, with white background
        printf "\033[${fg2};${bg2}m%-${w}s\033[0m" "Fg2: ${fg2}"  # Bright foreground color

        #----------------------------------------------------------------------
        printf "  "

        # Column-1: Print bold standard foreground colors, with black background 
        printf "\033[${fg1};${bg1};1m%-${w}s\033[0m" "Fg1: ${fg1}"  # Standard foreground color

        # Column-2: Print bold bright foreground colors, with black background
        printf "\033[${fg2};${bg1};1m%-${w}s\033[0m" "Fg2: ${fg2}"  # Bright foreground color

        # Column-1: Print bold standard foreground colors, with white background 
        printf "\033[${fg1};${bg2};1m%-${w}s\033[0m" "Fg1: ${fg1}"  # Standard foreground color

        # Column-2: Print bold bright foreground colors, with white background
        printf "\033[${fg2};${bg2};1m%-${w}s\033[0m" "Fg2: ${fg2}"  # Bright foreground color

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
    #printf "\n%-30s%-30s  %-30s%-30s\n" "White Foreground Color" "Black Foreground Color" "White-Bold Foreground Color" "Black-Bold Foreground Color"
    printf "\n%-30s%-30s  %-30s%-30s\n" "-White Foreground Color------" "-Black Foreground Color------" "-White-Bold Foreground Color-" "-Black-Bold Foreground Color--"

    fg1=37  # white foreground
    fg2=30  # black foreground
    bg1=40  # black background
    bg2=100 # bright-black background

    for f in {0..7}; do
        # Column-1: Print standard white foreground color, standard background colors
        printf "\033[${fg1};${bg1}m%-${w}s\033[0m" "Bg1: ${bg1}"

        # Column-2: Print standard white foreground color, bright background colors
        printf "\033[${fg1};${bg2}m%-${w}s\033[0m" "Bg2: ${bg2}"

        # Column-1: Print standard white foreground color, standard background colors
        printf "\033[${fg2};${bg1}m%-${w}s\033[0m" "Bg1: ${bg1}"

        # Column-2: Print standard white foreground color, bright background colors
        printf "\033[${fg2};${bg2}m%-${w}s\033[0m" "Bg2: ${bg2}"

        #----------------------------------------------------------------------
        printf "  "

        # Column-1: Print bold standard white foreground color, standard background colors
        printf "\033[${fg1};${bg1};1m%-${w}s\033[0m" "Bg1: ${bg1}"

        # Column-2: Print bold standard white foreground color, bright background colors
        printf "\033[${fg1};${bg2};1m%-${w}s\033[0m" "Bg2: ${bg2}"

        # Column-1: Print bold standard black foregrond color,standard background colors
        printf "\033[${fg2};${bg1};1m%-${w}s\033[0m" "Bg1: ${bg1}"

        # Column-2: Print bold standard black foreground color,bright background colors
        printf "\033[${fg2};${bg2};1m%-${w}s\033[0m" "Bg2: ${bg2}"

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

