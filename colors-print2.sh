#!/usr/bin/env bash

# Function to print colors in columns
print_colors() {
    echo -e "\n---Standard Background Colors-----------------------------------------------------------------------------------------------------------------"

    # Define the number of columns
    local columns=8
    local count=0

    # Loop through standard foreground colors (0-7)
    for fg in {30..37}; do
        # Loop through standard background colors (0-7)
        for bg in {40..47}; do
            # Print the colored text
            printf "\033[${fg};${bg}m Fg: ${fg} Bg:  ${bg} \033[0m  "
            ((count++))
            # Check if we reached the column limit
            if (( count % columns == 0 )); then
                printf "\n"  # New line after reaching the column limit
            fi
        done
    done

    #--------------------------------------------------------------------------
    # Print a separator for clarity
    echo -e "\n---Bright Background Colors-------------------------------------------------------------------------------------------------------------------"

    local columns=8
    count=0  # Reset count for bright colors

    # Loop through bright foreground colors (90-97)
    for fg in {90..97}; do
        # Loop through standard background colors (0-7)
        for bg in {100..107}; do
            # Print the colored text with bright foreground
            printf "\033[${fg};${bg}m Fg: ${fg} Bg: ${bg} \033[0m  "
            ((count++))
            # Check if we reached the column limit
            if (( count % columns == 0 )); then
                printf "\n"  # New line after reaching the column limit
            fi
        done
    done

    # New line at the end of output
    printf "\n"
}

# Call the function to print colors
print_colors

