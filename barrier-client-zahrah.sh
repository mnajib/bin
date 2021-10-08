#!/usr/bin/env bash

server=192.168.123.152
#client=$HOST
client=zahrah

#barrierc --no-daemon --restart --name $client --enable-crypto $server
barrierc --no-daemon --restart --name $client $server
