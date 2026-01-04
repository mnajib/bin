#!/usr/bin/env bash

# We use the clean path structure from the raudah machine, excluding the polluting paths
# Note: The nix-store hashes might differ but the structure is the same.

#export XDG_DATA_DIRS_CLEAN="/nix/store/kmcwjff5v2c6f676rx2x2r01wdv2p52s-desktops/share:/home/najib/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/home/najib/.nix-profile/share:/home/najib/.local/state/nix/profile/share:/etc/profiles/per-user/najib/share:/nix/var/nix/profiles/default/share:/run/current-system/sw/share"

# Run the app using the cleaned environment variable:
#XDG_DATA_DIRS="$XDG_DATA_DIRS_CLEAN" flatpak run org.vinegarhq.Sober

XDG_DATA_DIRS="/nix/store/kmcwjff5v2c6f676rx2x2r01wdv2p52s-desktops/share:/home/najib/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/home/najib/.nix-profile/share:/home/najib/.local/state/nix/profile/share:/etc/profiles/per-user/najib/share:/nix/var/nix/profiles/default/share:/run/current-system/sw/share" flatpak --verbose run org.vinegarhq.Sober
