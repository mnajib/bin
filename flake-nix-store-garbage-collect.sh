#!/usr/bin/env bash

# nix-collect-garbage: used to clean up unused Store Objects in /nix/store.
# nix-collect-garbage -d

# In Nix Flakes, the corresponding command is
nix store gc --debug
