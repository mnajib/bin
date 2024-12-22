#!/usr/bin/env bash

pactl unload-module module-loopback
pactl unload-module module-null-sink
sleep 1

# Create a Virtual Sink
pactl load-module module-null-sink sink_name=VirtualOutput sink_properties=device.description="Virtual Output"
sleep 1

# Identify Sink Names
#pactl list short sinks
#pactl list short sources

# Create a Loopback from Virtual Output to GS3 Analog Stereo
pactl load-module module-loopback source=VirtualOutput.monitor sink=alsa_output.usb-GS3_GS3_20180508-00.analog-stereo
sleep 1

# Set the  GS3 sink volume. Cannot be less than 88%, the GS3 not output any sound if less than that
pactl set-sink-volume alsa_output.usb-GS3_GS3_20180508-00.analog-stereo 100%
sleep 1

# Set the Virtual Sink volume
pactl set-sink-volume VirtualOutput 60%
sleep 1

# Set the Virtual Sink as default output
pactl set-default-sink VirtualOutput
sleep 1
