#!/usr/bin/env bash

df -hT | grep "% /$" | awk '{ printf "%s %s\n", strftime("%Y-%m-%d %H:%M:%S"), $0 }'
