#!/usr/bin/env bash

# Delete old system profiles to mark unused files for removal:
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

# Run Garbage Collection (GC) (the procedure that permanently deletes unreferenced files from /nix/store):
sleep 1
sudo nix-collect-garbage -d

# (Optional) Run store optimization (a process that replaces identical duplicate files across different packages with hard links to save space):
#sleep 1
#nix-store --optimise
