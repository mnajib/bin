#!/bin/bash

####################################################
# start vpn
####################################################

#cp -vR "/mnt/c/Users/najib/AppData/Roaming/WatchGuard/Mobile VPN/*" /etc/openvpn/fcnvpn/fcn0/
cd /etc/openvpn/fcnvpn
openvpn --config fcn0/client.ovpn

