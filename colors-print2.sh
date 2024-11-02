#!/usr/bin/env bash

# with foreground: standard
print_colors() {
    #echo -e "\n---Standard Background Colors-----------------------------------------------------------------------------------------------------------------"
    echo -e "---Standard Foreground Colors-----------------------------------------------------------------------------------------------------------------"

    echo -e "\n   with Standard Background Colors"

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

    #echo -e "\n---Bright Background Colors-------------------------------------------------------------------------------------------------------------------"
    echo -e "\n   with Bright Background Colors"

    local columns=8
    count=0  # Reset count for bright colors

    # Loop through bright foreground colors (90-97)
    for fg in {30..37}; do
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

# with foreground: bright
print_colors2() {
    echo -e "---Bright Foreground Colors-------------------------------------------------------------------------------------------------------------------"

    echo -e "\n   with Standard Background Colors"
    # Define the number of columns
    local columns=8
    local count=0

    # Loop through standard foreground colors (0-7)
    for fg in {90..97}; do
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

    echo -e "\n   with Bright Background Colors"
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

# with foreground: bold
print_colors3() {
    echo -e "---Bold Foreground Colors---------------------------------------------------------------------------------------------------------------------"

    echo -e "\n   with Standard Background Colors"
    # Define the number of columns
    local columns=8
    local count=0

    # Loop through standard foreground colors (0-7)
    for fg in {30..37}; do
        # Loop through standard background colors (0-7)
        for bg in {40..47}; do
            # Print the colored text
            printf "\033[${fg};${bg};1m Fg: ${fg} Bg:  ${bg} \033[0m  "
            ((count++))
            # Check if we reached the column limit
            if (( count % columns == 0 )); then
                printf "\n"  # New line after reaching the column limit
            fi
        done
    done

    echo -e "\n   with Bright Background Colors"
    local columns=8
    count=0  # Reset count for bright colors

    # Loop through bright foreground colors (90-97)
    for fg in {30..37}; do
        # Loop through standard background colors (0-7)
        for bg in {100..107}; do
            # Print the colored text with bright foreground
            printf "\033[${fg};${bg};1m Fg: ${fg} Bg: ${bg} \033[0m  "
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

# with foreground: bright bold
print_colors4() {
    echo -e "---Bright Bold Foreground Colors--------------------------------------------------------------------------------------------------------------"

    echo -e "\n   with Standard Background Colors"
    # Define the number of columns
    local columns=8
    local count=0

    # Loop through standard foreground colors (0-7)
    for fg in {90..97}; do
        # Loop through standard background colors (0-7)
        for bg in {40..47}; do
            # Print the colored text
            printf "\033[${fg};${bg};1m Fg: ${fg} Bg:  ${bg} \033[0m  "
            ((count++))
            # Check if we reached the column limit
            if (( count % columns == 0 )); then
                printf "\n"  # New line after reaching the column limit
            fi
        done
    done

    echo -e "\n   with Bright Background Colors"
    local columns=8
    count=0  # Reset count for bright colors

    # Loop through bright foreground colors (90-97)
    for fg in {90..97}; do
        # Loop through standard background colors (0-7)
        for bg in {100..107}; do
            # Print the colored text with bright foreground
            printf "\033[${fg};${bg};1m Fg: ${fg} Bg: ${bg} \033[0m  "
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

# Function to display help/usage message
show_help() {
    #echo "Usage: $0 <function_name> [args]"
    echo "Usage: $0 [function_name]"
    echo
    echo "Available functions:"
    echo "  1        Displays a message from printColor1."
    echo "  2        Displays a message from printColor2."
    echo "  3        Displays a message from printColor2."
    echo "  4        Displays a message from printColor2."
    echo
    echo "Example:"
    #echo "  $0 printColor1"
    #echo "  $0 printColor2 arg1 arg2"
    echo "  $0 1"
    echo "  $0 2"
}

## Check if a function name was provided as an argument
#if [[ $# -gt 0 ]]; then
#    # Call the specified function
#    case $1 in
#        print_colors|1)
#            print_colors "${@:2}"  # Pass any additional arguments to the function
#            ;;
#        print_colors2|2)
#            print_colors2 "${@:2}"  # Pass any additional arguments to the function
#            ;;
#        print_colors3|3)
#            print_colors3 "${@:2}"  # Pass any additional arguments to the function
#            ;;
#        print_colors4|4)
#            print_colors4 "${@:2}"  # Pass any additional arguments to the function
#            ;;
#        all|0)
#            print_colors
#            print_colors2
#            print_colors3
#            print_colors4
#            ;;
#        help|--help|-h)
#            show_help
#            ;;
#        *)
#            echo "'$1' is not a known function name."
#            show_help
#            exit 1
#            ;;
#    esac
#else
#    #echo "No function name provided. Please specify a function to call."
#    #show_help
#    print_colors
#    print_colors2
#    print_colors3
#    print_colors4
#fi

# Check if a function name was provided as an argument
if [[ $# -gt 0 ]]; then
    for func in "$@"; do # Iterate over all provided arguments
        # Call the specified function
        case $func in
            print_colors|1)
                print_colors "${@:2}"  # Pass any additional arguments to the function
                ;;
            print_colors2|2)
                print_colors2 "${@:2}"  # Pass any additional arguments to the function
                ;;
            print_colors3|3)
                print_colors3 "${@:2}"  # Pass any additional arguments to the function
                ;;
            print_colors4|4)
                print_colors4 "${@:2}"  # Pass any additional arguments to the function
                ;;
            all|0)
                print_colors
                print_colors2
                print_colors3
                print_colors4
                ;;
            help|--help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "'$1' is not a known function name."
                show_help
                exit 1
                ;;
        esac
    done
else
    #echo "No function name provided. Please specify a function to call."
    #show_help
    print_colors
    print_colors2
    print_colors3
    print_colors4
fi

#./colors-print2.sh print_colors2
