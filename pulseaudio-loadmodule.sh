#!/bin/bash
pactl load-module module-combine-sink sink_name=g1 slaves=1,2,3 sink_properties=device.description=g1
pactl load-module module-combine-sink sink_name=g2 slaves=1,3 sink_properties=device.description=g2
pactl load-module module-combine-sink sink_name=g3 slaves=1,2 sink_properties=device.description=g3
pactl load-module module-combine-sink sink_name=g4 slaves=2,3 sink_properties=device.description=g4
