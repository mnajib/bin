#!/run/current-system/sw/bin/env bash

nix-shell --packages cabal2nix --run "cabal2nix ." > default.nix
