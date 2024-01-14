#!/bin/bash

# list sinks
#pacmd list-sinks

# combine output to miniamp-a (bilik Naqib) & miniamp-b (bilik Nasuha)
#pacmd load-module module-combine-sink sink_name=gNaqibNasuha slaves=alsa_output.pci-0000_05_01.0.analog-stereo,alsa_output.pci-0000_05_02.0.analog-stereo sink_properties=device.description=gNaqibNasuha

# combine output (Master + Nasuha)
#pacmd load-module module-combine-sink sink_name=gMasterNasuha slaves=alsa_output.pci-0000_05_02.0.analog-stereo,alsa_output.pci-0000_00_1b.0.analog-stereo sink_properties=device.description=gMasterNasuha

# xfi
# built-in
pacmd load-module module-combine-sink sink_name=gMasterNasuha slaves=alsa_output.pci-0000_05_02.0.analog-stereo,alsa_output.pci-0000_00_1b.0.analog-stereo sink_properties=device.description=gMasterNasuha

## xfi --> blast --> Master
## build-in --> miniamp-y --> bilik Naqib

#pactl load-module module-combine-sink sink_name=g23 slaves=2,3 sink_properties=device.description=g23
##pactl load-module module-combine-sink sink_name=g234 slaves=2,3,4 sink_properties=device.description=g234
##pactl load-module module-combine-sink sink_name=g12345 slaves=1,2,3,4 sink_properties=device.description=g12345
##pactl load-module module-combine-sink sink_name=g24 slaves=2,4 sink_properties=device.description=g24
##pactl load-module module-combine-sink sink_name=g02 slaves=0,2 sink_properties=device.description=g02

# Remove the specific sink?
#pactl list modules
#pactl unload-module 34

# Chane sink name and description?

# Categorize the sink view:
# - application sink
# - virtual sink
