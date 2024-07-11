#!/usr/bin/env bash

file="$HOME/barrier-khadijah.conf"
server=khadijah

barriers --no-daemon --name $server --restart --disable-crypto --config $file
