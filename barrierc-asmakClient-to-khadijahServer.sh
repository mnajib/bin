#!/usr/bin/env bash

server=khadijah       # use keyboard and mouse from here
client=asmak    #

barrierc --no-daemon --disable-crypto --restart --name $client $server
