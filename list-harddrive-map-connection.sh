#!/usr/bin/env bash

grep '[0-9]' /sys/class/scsi_host/host{0..9}/unique_id | awk -F'/' '{print $0,$5}' | xargs -n2 sh -c 'echo -n "$0 - $1 - " ; (ls -l /sys/block/sd* | grep $1 ) || echo "no block device showing"'
