#!/usr/bin/env bash

# Ref:
#   terminfo(5)
#

for i in {0..255} ; do
    #------------------------------------------
    # Print the_color as background ...
    #------------------------------------------

    # ... with default foreground text
    printf "\e[0m"
    printf "\e[30;48;5;%sm%4d " "$i" "$i"
    #printf "\e[0;30;48;5;%sm%4d " "$i" "$i"

    # ... with black foreground text
    #printf "\e[0m"
    #printf "\e[30;5;48%sm%4d " "$i" "$i"
    #printf "\e[30;%sm%4d " "$i" "$i"
    printf "\e[30;%sm%4d " "$i" "$i"
    #printf "\e[0;90;48;5;%sm%4d " "$i" "$i"

    # ... with white foreground text
    printf "\e[0m"
    #printf "\e[97m%4d " "$i"
    printf "\e[0;37;48;5;%sm%4d " "$i" "$i"

    #------------------------------------------
    # Print the_color as foreground text ...
    #------------------------------------------

    # ... on default BG
    printf "\e[0m"
    #printf "\e[40m"
    printf "\e[40;38;5;%sm%4d " "$i" "$i"

    # ... on black BG
    #printf "\e[0;38;5;%sm%4d " "$i" "$i"
    #printf "\e[0;40;0;%sm%4d " "$i" "$i"
    printf "\e[0;38;5;%sm%4d " "$i" "$i"
    #printf "\e[0;100;5;%sm%4d " "$i" "$i"

    # ... on white BG
    #printf "\e[0m"
    #printf "\e[1;47m"
    #printf "\e[0;107m%4d " "$i"
    #printf "\e[0;107;%sm%4d " "$i" "$i"
    #printf "\e[0;48;5;%sm%4d " "$i" "$i"
    #printf "\e[47;%sm%4d " "$i" "$i"
    printf "\e[%s;5;47m%4d " "$i" "$i"

    #------------------------------------------
    # XXX:
    #------------------------------------------
    # default FG on black BG
    printf "\e[0m"
    printf " \e[37m%s " "blackBG-defaultFG"

    # white FG on black BG
    printf "\e[1;47;m%s " "blackBG-whiteFG"

    #------------------------------------------
    # Check whether to print new line
    #------------------------------------------
    #[ $(( ($i +  1) % 4 )) == 0 ] && set1=1 || set1=0
    #[ $(( ($i - 15) % 6 )) == 0 ] && set2=1 || set2=0
    #if ( (( set1 == 1 )) && (( i <= 15 )) ) || ( (( set2 == 1 )) && (( i > 15 )) ); then
        printf "\e[0m\n";
    #fi
done

