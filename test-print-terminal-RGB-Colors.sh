#!/usr/bin/env bash

#printf '\e[38;2;240;100;200m\e[48;2;200;255;50mHello World!\e[0m\n'
#           fg   RRR GGG BBB    bg   RRR GGG BB             reset

#printf '\e[38;2;%d;%d;%dm%s\e[0m\n' 0x00 0xA0 0xFF 'Hello World!'

# rgb color using hex code (0 - F)
colprint() (
   text="${1#'[#'??????']'}"
   r="${1%"$text"}"
   r="${r%']'}"
   r="${r#'[#'}"
   r="${r:-FFFFFF}"
   b="${r#????}"
   r="${r%??}"
   g="${r#??}"
   r="${r%??}"
   printf '\e[38;2;%d;%d;%dm%s\e[0m\n' "0x$r" "0x$g" "0x$b" "$text"
)

# rgb color using decimel code (0 - 255)
lorprint(){
   text="${1#'[#'??????']'}"
   r="${1%"$text"}"
   r="${r%']'}"
   r="${r#'[#'}"
   r="${r:-FFFFFF}"
   b="${r#????}"
   r="${r%??}"
   g="${r#??}"
   r="${r%??}"

   # #rrggbb colored text, with black background
   printf '\e[38;2;%d;%d;%dm%s\e[0m\n' "0x$r" "0x$g" "0x$b" "$text"
   # #rrggbb colored text, with white background
   printf '\e[38;2;%d;%d;%dm%s\e[0m\n' "0x$r" "0x$g" "0x$b" "$text"
   # White cololed text, with #rrggbb colored background
   printf '\e[38;2;%d;%d;%dm%s\e[0m\n' "0x$r" "0x$g" "0x$b" "$text"
   # Black colored text, with #rrggbb colored background
   printf '\e[38;2;%d;%d;%dm%s\e[0m\n' "0x$r" "0x$g" "0x$b" "$text"
}

# Usage:
#   najibPrint <text> <foregroundColor> <backgroundColor>
# Example:
#   najibPrint "text" "ff0000" "808080"
# Will return:
#   ...
#najibPrint(){
      # ... with black foreground text
      #printf "\e[30;48;5;%sm%4d " "$i" "$i"
#}

#colprint '[#FF0000]Test print with color #FF0000'
#colprint '[#FF0000]this is red text'
#colprint '[#BFFF00]this is lime text'
#colprint 'white again (default)'

#lorprint '[#FF0000]Test print with color #FF0000'
#lorprint '[#FF0000]this is red text'
#lorprint '[#BFFF00]this is lime text'
#lorprint 'white again (default)'

# Map single RGB component (0-255) to terminal colour component (0-5)
get_component() {
	local comp=${1%.*}
	if ((comp > 115)); then
		echo $(((comp - 116) / 40 + 2))
	elif ((comp > 47)); then
		echo 1
	else
		echo 0
	fi
}

# Map RGB triple to terminal colour
rgb_to_term() {
	local rgbcol=("$@")
	local rterm gterm bterm
	rterm=$(get_component "${rgbcol[0]}")
	gterm=$(get_component "${rgbcol[1]}")
	bterm=$(get_component "${rgbcol[2]}")
	echo $((16 + 36 * rterm + 6 * gterm + bterm))
}

rgb_to_term 255


printTestColor(){
#for r in {0..255} ; do
#for r in {0..100..2} ; do
#  for g in {0..100..2} ; do
#    for b in {0..100..2} ; do

      local i=$1
      #printf "%s %d" "$i" "$i"

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
      #printf "\e[40;38;5;%sm%4d " "$i" "$i"
      #printf '\e[38;2;%d;%d;%dm%s\e[0m\n' "0x$r" "0x$g" "0x$b" "--> $r,$g,$b"
      #printf '\e[38;2;%d;%d;%dm%s\e[0m\n' "0x$r" "0x$g" "0x$b" "--> $r,$g,$b"

      # ... on white BG
      printf "\e[107m%4d " "$i"

      #------------------------------------------
      # Check whether to print new line
      #------------------------------------------
      #[ $(( ($i +  1) % 4 )) == 0 ] && set1=1 || set1=0
      #[ $(( ($i - 15) % 6 )) == 0 ] && set2=1 || set2=0
      #if ( (( set1 == 1 )) && (( i <= 15 )) ) || ( (( set2 == 1 )) && (( i > 15 )) ); then
        printf "\e[0m\n"
      #fi

#    done
    #printf '\e[38;2;%d;%d;%dm%s\e[0m' "0x$r" "0x$g" "0x$b" "--> $r,$g,$b"
#  done
  #printf '\e[38;2;%d;%d;%dm%s\e[0m\n' "0x$r" "0x$g" "0x$b" "--> $r,$g,$b"
#done
}

#printTestColor 4
#printTestColor 14
#printTestColor 24
#printTestColor 34
#printTestColor 44
#printTestColor 54
#printTestColor 64
#printTestColor 74
#printTestColor 84
