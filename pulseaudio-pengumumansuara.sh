#!/bin/bash

#--------------------------------------------------------------------
# build-in sound card input
#$nputsource = alsa_input.pci-0000_00_1b.0.analog-stereo

# SB Live! EMU10k1 input
# ...

#--------------------------------------------------------------------
# build-in sound card output
#...

# SB Live! EMU10k1 output
#outputsink = alsa_output.pci-0000_05_01.0.analog-stereo

#--------------------------------------------------------------------
#pactl list sinks
#pactl list sources

pactl load-module module-loopback source="alsa_input.pci-0000_00_1b.0.analog-stereo" sink="alsa_output.pci-0000_05_01.0.analog-stereo"
#pactl load-module module-loopback source=${inputsource} sink=${outputsink}
