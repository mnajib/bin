#!/bin/sh
echo "Stopping firewall and allowing everyone..."
iptables=/sbin/iptables
$iptables -F
$iptables -X
$iptables -t nat -F
$iptables -t nat -X
$iptables -t mangle -F
$iptables -t mangle -X
$iptables -P INPUT ACCEPT
$iptables -P FORWARD ACCEPT
$iptables -P OUTPUT ACCEPT

#service iptables save
#chkconfig iptables off
#cat /proc/net/ip_tables_names

# display the natted connections on a Linux iptable firewall
#netstat-nat -n
# To display all connection by source IP called 192.168.1.100
#netstat-nat -s 192.168.1.100
# To display all connections by destination IP/hostname called laptop, enter:
#netstat-nat -s laptop
# To display SNAT connections
#netstat-nat -S
# To display DNAT connections
#netstat-nat -D
# To display NAT connections with protocol selection, enter:
#netstat-nat -np
# To display only connections to NAT box self i.e. doesn’t show SNAT & DNAT, enter:
#netstat-nat -L


