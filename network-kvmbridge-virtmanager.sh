#!/bin/bash

ifconfig eth0 0.0.0.0 up
#ip route del 192.168.123.0/24 dev eth0
#ip route del default via 192.168.123.1 dev eth0
#ip route add default via 192.168.123.1 dev br0

brctl addbr br0
brctl addif br0 eth0
dhclient br0
###########
ip route ls
###########
#default via 192.168.123.1 dev br0
#192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1
#192.168.123.0/24 dev br0  proto kernel  scope link  src 192.168.123.59
###########

###########
#ip route ls
###########
##default via 192.168.123.1 dev br0
##169.254.0.0/16 dev br0  scope link  metric 1000
##192.168.123.0/24 dev br0  proto kernel  scope link  src 192.168.123.59
###########

#ip addr ls
#brctl show

#ifconfig eth0 192.168.4.1 netmask 255.255.252.0 up
#inet 192.168.4.1/22 brd 192.168.7.255 scope global eth0
