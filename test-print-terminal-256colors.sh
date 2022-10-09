#!/usr/bin/env bash

for i in {0..255} ; do
    #------------------------------------------
    # Print the_color as background ...
    #------------------------------------------

    # ... with black foreground text
    printf "\e[30;48;5;%sm%4d " "$i" "$i"

    # ... with white foreground text
    printf "\e[97m%4d " "$i"

    #------------------------------------------
    # Print the_color as foreground text ...
    #------------------------------------------

    # ... on black BG
    printf "\e[40;38;5;%sm%4d " "$i" "$i"

    # ... on white BG
    printf "\e[107m%4d " "$i"

    #------------------------------------------
    # Check whether to print new line
    #------------------------------------------
    [ $(( ($i +  1) % 4 )) == 0 ] && set1=1 || set1=0
    [ $(( ($i - 15) % 6 )) == 0 ] && set2=1 || set2=0
    if ( (( set1 == 1 )) && (( i <= 15 )) ) || ( (( set2 == 1 )) && (( i > 15 )) ); then
        printf "\e[0m\n";
    fi
done

