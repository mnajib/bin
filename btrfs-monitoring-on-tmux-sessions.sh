#!/usr/bin/env bash

DEVICE1=""
DEVICE2=""
MOUNTPOINT1="/mnt/btr_pool1"
MOUNTPOINT2="/mnt/btr_pool2"

# Start new tmux session
#...

#
# Usage:
#   monitorScrubStatus /mnt/btr_pool1
#   monitorScrubStatus /mnt/btr_pool2
#
monitorInTmuxPane() {
    local MOUNTPOINT="$1"

    #tmux new-session 'watch btrfs scrub status /mnt/btr_pool1' \; \
    #    split-pane 'watch btrfs scrub status /mnt/btr_pool2' \; \
    #    split-window 'watch btrfs device stats -T /mnt/btr_pool1' \; \
    #    split-window 'watch btrfs device stats -T /mnt/btr_pool1'

    tmux split-pane "watch scrubStatus $MOUNTPOINT" \; \
        select-layout even-vertical

    #tmux select-layout even-vertical
    #tmux select-layout even-horizontal
}

printTitle(){
    local title="$1"
    echo '/##############################################'
    echo "| $1"
    echo '\##############################################'
    echo
}

printReportAll() {
    printTitle "btrfs filesystem show"
    filesystemShow
    echo
    printTitle "btrfs scrub status /mnt/btr_pool1"
    scrubStatus /mnt/btr_pool1
    echo
    printTitle "btrfs scrub status /mnt/btr_pool2"
    scrubStatus /mnt/btr_pool2
    echo
    printTitle "btrfs device stats /mnt/btr_pool1"
    deviceStats /mnt/btr_pool1
    echo
    printTitle "btrfs device stats /mnt/btr_pool2"
    deviceStats /mnt/btr_pool2
    echo
    printTitle "btrfs balance status /mnt/btr_pool1"
    balanceStatus /mnt/btr_pool1
    echo
    printTitle "btrfs balance status /mnt/btr_pool2"
    balanceStatus /mnt/btr_pool2
}

scrubStatus() {
    local MOUNTPOINT="$1"
    btrfs scrub status $MOUNTPOINT
}

deviceStats() {
    local MOUNTPOINT="$1"
    btrfs device stats -T $MOUNTPOINT
}

balanceStatus() {
    local MOUNTPOINT="$1"
    btrfs balance status $MOUNTPOINT;
}

filesystemShow() {
    #local MOUNTPOINT="$1"
    btrfs filesystem show --human-readable
}

about(){
    #echo "$0"
    echo "Version: 0.0.1"
    echo "Author: Muhammad Najib Bin Ibrahim"
    echo "Email: mnajib@gmail.com"
}

version(){
    echo "$0 v0.0.1"
}

usage(){
    echo "Usage: $0 [OPTIONS]"
    echo "OPTIONS:"
    echo "  -h, --help        Display this help message."
    echo "  -v, --version     Display this script version."
    echo "  -a, --about       Display about this script."
}

match() {
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -v|--version)
      version
      exit 0
      ;;
    -a|--about)
      about
      exit 0
      ;;
    *)
      # without any arguments
      if [ -z "$1" ]; then #if [ -n "$1"]; then
        printReportAll
      else #If any other argument(s)
        echo "Invalid input. Please enter a valid input."
        exit 1
      fi
      # without any arguments
      #printReportAll
      ;;
  esac
}

main() {
    match "$@"
}

#printReportAll
main "$@"
