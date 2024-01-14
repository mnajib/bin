#!/bin/bash

# rt.fcn.my 192.168.100.37
# mysql.fcn.my 192.168.100.24

net="192.168.98.1"
dev="tun0"

# remove unused routing
sleep 1
ip route del 10.238.62.112/30 via $net dev $dev
ip route del 10.0.5.0/24 via $net dev $dev
ip route del 10.0.6.0/24 via $net dev $dev
ip route del 10.1.0.0/16 via $net dev $dev
ip route del 10.41.0.0/16 via $net dev $dev
ip route del 10.238.0.0/16 via $net dev $dev
ip route del 10.238.62.114 via $net dev $dev
ip route del 172.16.52.31 via $net dev $dev
ip route del 192.168.1.0/24 via $net dev $dev
ip route del 192.168.4.0/24 via $net dev $dev
ip route del 192.168.7.0/24 via $net dev $dev
ip route del 192.168.11.236/30 via $net dev $dev
ip route del 192.168.13.64/28 via $net dev $dev
ip route del 192.168.15.0/27 via $net dev $dev
ip route del 192.168.22.0/24 via $net dev $dev
ip route del 192.168.26.0/24 via $net dev $dev
ip route del 192.168.30.0/24 via $net dev $dev
ip route del 192.168.40.0/24 via $net dev $dev
ip route del 192.168.59.0/24 via $net dev $dev
ip route del 192.168.69.0/24 via $net dev $dev
ip route del 192.168.77.0/24 via $net dev $dev
ip route del 192.168.99.0/24 via $net dev $dev
ip route del 192.168.104.0/24 via $net dev $dev
ip route del 200.1.0.0/16 via $net dev $dev

# repair routing
#ip route del 192.168.100.0/24 via 192.168.100.233 dev tun0
#ip route add 192.168.100.232/29 via 192.168.100.234 dev tun0
##ip route add 192.168.100.232/29 proto kernel scope link src 192.168.100.234 dev tun0
#
# 192.168.100.37 (rtprod)
# 192.168.100.24 (rtmysql)
##ip route add 192.168.100.
#ip route del 192.168.100.0/24 via 192.168.100.234 dev tun0
