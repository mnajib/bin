#!/usr/bin/env bash

function sync1() {
    # rsync --dry-run --remove-source-files -azP \
    #rsync --dry-run -avPu --ignore-existing \
    rsync -avPu --ignore-existing \
    --exclude bin \
    --exclude .xmonad \
    --exclude '.nix*' \
    --exclude .cache \
    --exclude .bash_history \
    --exclude .gitconfig \
    --exclude .nix-defexpr \
    --exclude .minetest \
    /home/najib.mahirah.bak-2021-11-23/ \
    /home/najib
}

sync1
