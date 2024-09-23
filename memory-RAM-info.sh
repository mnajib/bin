#!/usr/bin/env bash

sudo dmidecode | awk '/^Memory Device$/ {main=1; print; next} main && /^[ \t]*Size: .*|^[ \t]*Bank Locator: .*|^[ \t]*Speed: .*/ {print}'
