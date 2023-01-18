#!/usr/bin/env bash

# tput_colors - Demonstrate color combinations.

for fg_color in 0 8 1 9 2 10 3 11 4 12 5 13 6 14 7 15; do
  set_foreground=$(tput setaf $fg_color)
  for bg_color in {0..7}; do
    set_background=$(tput setab $bg_color)
    echo -n $set_background$set_foreground
    printf ' F:%2s B:%2s ' $fg_color $bg_color
  done
  echo $(tput sgr0)
done

