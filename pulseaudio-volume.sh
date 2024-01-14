#!/bin/bash
# vim:set nowrap:et=2 sw=2:ts=2 

# 1 - ca - dapur
# 2 - live - bilik
# 3 - xfi - store

#pactl load-module module-combine-sink sink_name=g1 slaves=1,2,3 sink_properties=device.description=g1
#pactl load-module module-combine-sink sink_name=g2 slaves=1,3 sink_properties=device.description=g2
#pactl load-module module-combine-sink sink_name=g3 slaves=1,2 sink_properties=device.description=g3
#pactl load-module module-combine-sink sink_name=g4 slaves=2,3 sink_properties=device.description=g4

# print playback (all streams)
#function printPlayback() {
function printSinkInputs() {
  echo "Playback (sink-inputs):"
  ##pactl list sink-inputs | egrep "^Sink Input|Volume|media.name|application.name" | sed "s/^\t*//g" | sed "s/^\ *//g" | sed "/^Sink/ s/^Sink/\nSink/g"
  ##pactl list sink-inputs | egrep "^Sink Input|Volume|media.name|application.name|Mute" | sed "s/^\t*//g" | sed "s/^\ *//g" | sed "/^Sink/ s/^Sink/\nSink/g"
  ##pactl list sink-inputs | egrep "^Sink Input|Volume|media.name|application.name|Mute" | sed "s/^\t*//g" | sed "s/^\ *//g" | sed "/^Sink/ s/^Sink/\nSink/g" | sed "/^Sink\ Input/! s/^/\ \ /g"
  #pactl list sink-inputs | egrep "^Sink Input|Volume|media.name|application.name|Mute|Sink\:" | sed "s/^\t*//g" | sed "s/^\ *//g" | sed "/^Sink/ s/^Sink\ Input/\nSink\ Input/g" | sed "/^Sink\ Input/! s/^/\ \ /g"
  ##pactl list sink-inputs | egrep "^Sink Input|Volume|media.name|application.name|Mute|Sink\:" | sed "s/^\t*//g" | sed "s/^\ *//g" | sed "/^Sink/ s/^Sink\ Input/\nSink\ Input/g" | sed "/^Sink\ Input/! s/^/\ \ /g" | sed "/Sink:/ s/$/ (`_sinkDesc $0 3`)/"
  s=`pactl list sink-inputs | egrep "^Sink Input|Volume|media.name|application.name|Mute|Sink\:" | sed "s/^\t*//g" | sed "s/^\ *//g" | sed "/^Sink/ s/^Sink\ Input/\nSink\ Input/g" | sed "/^Sink\ Input/! s/^/\ \ /g"`

  #echo $s | sed "/Sink: / s/$/ lala/g"

  echo "$s"
  #echo ""
  echo '
To change sink-input mute/unmute (1 for mute, 0 for unmute):
  pactl set-sink-input-mute ${sink_input_id} ${nakmuteke}
To change sink-input volume (target volume range from 0% to 100%):
  pactl set-sink-input-volume ${sink_input_id} ${target_volume}%

To change routing for sink-input to other sink(output)
  pactl move-sink-input ${sinkInputId} ${sinkOutputId}
  '
}

# print output devices (all output devices)
#function printOutputDevices() {
function printSinks() {
  echo "Output Devices (sinks):"
  #pactl list sinks | egrep "^Sink|Name|Descrip|Volume" | sed "s/^\t*//g" | sed "s/^\ *//g" | grep -v "Base Volume" | sed "/^Name/ s/^Name/\nName/g"
  #pactl list sinks | egrep "^Sink|Name|Descrip|Volume" | sed "s/^\t*//g" | sed "s/^\ *//g" | grep -v "Base Volume" | sed "/^Sink/ s/^Sink/\nSink/g"
  #pactl list sinks | egrep "^Sink|Name|Descrip|Volume|Mute" | sed "s/^\t*//g" | sed "s/^\ *//g" | grep -v "Base Volume" | sed "/^Sink/ s/^Sink/\nSink/g"
  #pactl list sinks | egrep "^Sink|Name|Descrip|Volume|Mute" | sed "s/^\t*//g" | sed "s/^\ *//g" | grep -v "Base Volume" | sed "/^Sink/ s/^Sink/\nSink/g" | sed "/^Sink/! s/^/\ \ /g"
  pactl list sinks | egrep "^Sink|Name|Descrip|Volume|Mute|combine\.slaves" | sed "s/^\t*//g" | sed "s/^\ *//g" | grep -v "Base Volume" | sed "/^Sink/ s/^Sink/\nSink/g" | sed "/^Sink/! s/^/\ \ /g"
  #echo ""
  echo '
To change sink mute/unmute (1 for mute, 0 for unmute):
  pactl set-sink-mute ${sink_id} ${nakmuteke}
To change sink volume (target_volume range from 0% to 100%):
  pactl set-sink-mute ${sink_id} ${target_volume}%

To combine sink
  pactl load-module module-combine-sink sink_name=g24 slaves=2,4 sink_properties=device.description=g24
  pactl load-module module-combine-sink sink_name=g23 slaves=2,3 sink_properties=device.description=g23
  pactl load-module module-combine-sink sink_name=g234 slaves=2,3,4 sink_properties=device.description=g234
To remove specific sink
  pactl list modules
  pactl unload-module 34

To karaoke
  pactl load-module module-loopback latency_msec=1
  OR
  paman
  pacat -r --latency-msec=1 -d  alsa_input.pci-0000_00_1b.0.analog-stereo | pacat -p --latency-msec=1 -d  alsa_output.pci-0000_00_1b.0.analog-stereo
To not karaoke
  pacmd list-modules
  pactl unload-module 27

'
}

function _sinkDesc() {
  #$1 2 | sed "1,/^Sink\ #$2/ s/.*//" | sed "1,/Name:\ / s/.*//" | sed "/Mute:\ /,$ s/.*//" | grep "Desc" | sed "s/.*: //"
  desc=`$1 2 | sed "1,/^Sink\ #$2/ s/.*//" | sed "1,/Name:\ / s/.*//" | sed "/Mute:\ /,$ s/.*//" | grep "Desc" | sed "s/.*: //"`
  echo $desc

  #return $desc
}

# set mute/unmute 
# $nakmuteke = 1	# mute
# $nakmuteke = 0	# not mute / un-mute
function muteSinkInput() {
  sink_input_id=$1
  nakmuteke=$2
  pactl set-sink-input-mute ${sink_input_id} ${nakmuteke}
}

function muteSink() {
  sink_id=$1
  nakmuteke=$2
  pactl set-sink-mute ${sink_id} ${nakmuteke}
}

# TODO: Change routing for sink-input to other sink(output)
function change_play_sink(){
  sinkinput_id=$1
  sinkoutput_old_id=$2
  sinkoutput_new_id=$3
  
  #move-(sink-input|source-output) #N SINK|SOURCE
  #move-sink-input 34 8
  move-sink-input ${sinkInputId} ${sinkOutputId}

  #pactl move-sink-input 38 8
  #pactl set-sink-input-volume 38 100%
}

# print current volume
#printPlayback
#printOutputDevices
#
#printSinkInputs
#printSinks

# set mute/unmute 
#...

# tools to consider --> zenity?

# set volume
#...
case "$1" in
  printPlayback|1)
    printSinkInputs
    ;;
  printOutputDevices|2)
    printSinks
    ;;
  status)
    printSinkInputs
    echo "------------------------"
    printSinks
    ;; 
  sinkDesc)
    _sinkDesc $0 $2
    ;;
  *)
    echo $"Usage: $0 {1|printPlayback|2|printOutputDevices|status}"
    exit 1
esac

