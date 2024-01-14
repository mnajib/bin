#!/bin/bash

pacmd load-module module-combine-sink sink_name=sinkgroup1 slaves=alsa_output.pci-0000_00_1b.0.analog-stereo,alsa_output.pci-0000_05_00.0.analog-stereo sink_properties=device.description=sinkgroup1
pacmd set-card-profile 1 "<output:analog-surround-51>"
