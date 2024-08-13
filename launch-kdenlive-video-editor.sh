#!/usr/bin/env bash
nix-shell -I nixpkgs=channel:nixos-unstable -p libsForQt5.kdenlive glaxnimate ffmpeg --run kdenlive
