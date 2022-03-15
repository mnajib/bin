#!/usr/bin/env bash

# To get nmcli usage examples
#man 7 nmcli-examples

# Get all radio status
#nmcli radio
# enable all radio
nmcli radio all on

# To get SSID of available wifi APs
#nmcli device wifi list

# Connect to wifi network
#nmcli --ask device wifi connect "$SSID"

# To get devices state/connection
#nmcli device

# To get device info
#nmcli -p -f general,wifi-properties device show $DEVICE

nmcli connection show
nmcli connection up b996e2ba-0f0a-41d8-9d1a-2b32e55ceee8 -a
#nmcli connection up b996e2ba-0f0a-41d8-9d1a-2b32e55ceee8 password Naqib123Nasuha456Naim789
