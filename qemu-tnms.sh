#!/bin/bash

qemu-system-x86_64 \
-m 256 \
-redir tcp:5555::80 \
-redir tcp:5556::445 \
-redir tcp:5557::22 \
-hda /media/sda6-data/DATA/_virtualbox.VMs/tnms/TNMS_live2.vmdk &

#firefox http://localhost:5555/

#### on qemu guest
#service iptables stop
#dhclient eth1
#echo 'nameserver 8.8.8.8' > /etc/resolv.conf
#echo 'nameserver 8.8.4.4' >> /etc/resolv.conf

