#!/usr/bin/env bash
nix-shell -p inxi --run 'inxi -Gxx; echo; inxi -Axx'
