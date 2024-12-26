#!/usr/bin/env bash

ls -FilahR /dev/disk/by-path/ | grep "sd[a-z]$"
