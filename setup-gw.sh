#!/bin/bash

IFIN="eth0"
#IFIN="br0" #eth0"
IFOUT="wlan0"

iptables -F
iptables -t nat -F
iptables -t mangle -F

iptables -X
iptables -t nat -X
iptables -t mangle -X

iptables -t nat -A POSTROUTING -o $IFOUT -j MASQUERADE
iptables -A FORWARD -i $IFIN -j ACCEPT
#iptables -A FORWARD -i $IFIN -o $IFOUT -m state --state RELATED,ESTABLISHED -j ACCEPT

echo 1 > /proc/sys/net/ipv4/ip_forward
