#!/usr/bin/env bash

#
# OK turns out I just had a few more linux commands to learn to install fonts manually.
# In the end this is what I did:
# Moved all the TTF files for Input Mono into ~/.local/share/fonts, and ran the following commands (seperately):
#
#fc-cache -f -v
#fc-list | grep "Input"
#
# fc-cache seemed to flush the cache for fonts, fc-list with the grep printed out the names and styles of the installed Input fonts which I could then use in config.
# Alacritty config was able to switch the fonts out on the fly, the nix config font changes required a reboot.
#

# Adding personal fonts to ~/.fonts doesn't work
# The ~/.fonts directory is being deprecated upstream[1]. It already doesn't work in NixOS.
# The new preferred location is in $XDG_DATA_HOME/fonts, which for most users will resolve to ~/.local/share/fonts

#rm -vRf ~/.cache/fontconfig
#fc-cache -r

ln -s ~/.fonts ~/.local/share/fonts
fc-cache -f -v

#grep /fonts ~/.local/share/xorg/Xorg.0.log
#nix-shell -p xlsfonts
#xlsfonts
#xset -q
#xset -q | grep -i font | sed "s/,/\n/g" | less
#
# Xorg does not search recursively through the /usr/share/fonts/ directory like Fontconfig does. To add a path, the full path must be used:
#Section "Files"
#    FontPath     "/usr/share/fonts/local/"
#EndSection
#
# If you want font paths to be set on a per-user basis, you can add and remove font paths from the default by adding the following line(s) to ~/.xinitrc:
# Prepend a custom font path to Xorg's list of known font paths
#xset +fp /usr/share/fonts/local/
# Remove the specified font path from Xorg's list of known font paths
#xset -fp /usr/share/fonts/sucky_fonts/
