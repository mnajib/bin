#!/usr/bin/env bash
rsync -avz najib@khadijah:~/.fonts .
#fc-list -v | grep -i edward
ln -s ~/.fonts ~/.local/share/fonts
rm -vRf ~/.cache/fontconfig
fc-cache --really-force --verbose
#fc-list -v | grep -i edward
