#!/usr/bin/env bash

server=192.168.123.152
#client=$HOST
client=asmak

#barrierc --no-daemon --restart --name $client --enable-crypto $server
barrierc --no-daemon --restart --name $client $server
