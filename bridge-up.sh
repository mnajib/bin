ifconfig eth0 down
#ip ...

brctl addbr br0
brctl addif br0 eth0

ifconfig eth0 up
ifconfig eth0 0.0.0.0

ifconfig br0 up
dhclient br0
#ifconfig br0 10.0.3.166

#...
