#!/usr/bin/env bash

nix-shell -I nixpkgs=channel:nixos-unstable -p python38Packages.youtube-dl

##youtube-dl https://www.youtube.com/playlist?list=PLr-mGUA8J2jZhxMrL3aIMztK8ahe3j3J5
##youtube-dl -F https://www.youtube.com/playlist?list=PLr-mGUA8J2jZhxMrL3aIMztK8ahe3j3J5
##youtube-dl -f22 https://www.youtube.com/playlist?list=PLr-mGUA8J2jZhxMrL3aIMztK8ahe3j3J5

# Working
#~/bin/yt-dlp https://www.youtube.com/playlist?list=PLr-mGUA8J2jZhxMrL3aIMztK8ahe3j3J5
