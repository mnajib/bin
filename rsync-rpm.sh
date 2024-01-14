#!/bin/bash

#url="$1"
#des="$2"

#rsync -av rsync://rsync.mirrorservice.org/sites/mirror.centos.org/5/ /home/ned/mirror/5

#$url "http://yum.boundlessgeo.com/suite/v45/rhel/6/x86_64/"
#$des "/home/najib/DATA/vnet/_opengeo.upgrade/mirror/suite/v45/rhel/6/x86_64"
#url='https://apt.boundlessgeo.com/suite/v45/ubuntu/'
#des='/home/najib/DATA/_vnet.clients/_JPBD/_opengeo.upgrade/_ubuntu/_suite-v45-ubuntu/'
url='http://apt.postgresql.org/pub/repos/apt/pool/main/p/postgresql-9.4/'
des='/home/najib/DATA/_vnet.clients/_JPBD/_postgresql-upgrade/_installer-for-ubuntu/'

#rsync -av ${url} ${des}

#mkdir -p "/home/najib/DATA/vnet/_opengeo.upgrade/mirror/suite/v45/rhel/6/x86_64"
#mkdir -p "$des"
cd ${des}
#wget -mkx -e robots=off http://the-site-you-want-to-mirror.com
wget -w 2 -mkx -e robots=off ${url}
#wget -w 2 -mkx ${url}
#wget -w 2 -mkx -e robots=off "http://yum.boundlessgeo.com/suite/v45/rhel/6/x86_64/"
#wget -w 2 -mkx -e "$url"
