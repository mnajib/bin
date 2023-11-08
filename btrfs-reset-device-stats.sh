#!/usr/bin/env bash

mountpoint="$1"

btrfs device stats -z $mountpoint
