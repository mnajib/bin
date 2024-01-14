#!/bin/bash

cd /etc/openvpn/fcnvpn
xterm -e openvpn --config fcn0/client.ovpn &
sleep 10
ip route del 192.168.1.0/24 via 192.168.100.233 dev tun0
sleep 1
ip route ls
