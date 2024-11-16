#!/usr/bin/env bash

FILE="${HOME}/.config/barrier/barrier-khadijah.conf"

#barriers --no-daemon --name khadijah --restart --disable-crypto --config barriers-khadijah.conf
#barriers --no-daemon --name khadijah --restart --disable-crypto --config barrier-khadijah.conf
barriers --no-daemon --name khadijah --restart --disable-crypto --config "${FILE}"
