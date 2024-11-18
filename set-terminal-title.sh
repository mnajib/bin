#!/usr/bin/env bash

new_title=$1

set_title() {
  echo -e "\033]0;${1}\007"
}

#set_title "My New Title"
set_title "$1"
