#!/bin/bash
#pactl load-module module-ladspa-sink sink_name=ladspa_output.fastLookaheadLimiter label=fastLookaheadLimiter plugin=fast_lookahead_limiter_1913 master=alsa_output.pci-0000_05_02.0.analog-stereo control=20,0,0.3
#pactl load-module module-ladspa-sink sink_name=ladspa_output.dyson_compress_1403.dysonCompress label=dysonCompress plugin=dyson_compress_1403 master=ladspa_output.fastLookaheadLimiter control=0,0.5,0.5,0.99
#pactl set-default-sink ladspa_output.dyson_compress_1403.dysonCompress

#pactl unload-module module-ladspa-sink sink_name=ladspa_output.fastLookaheadLimiter label=fastLookaheadLimiter plugin=fast_lookahead_limiter_1913 master=alsa_output.pci-0000_05_02.0.analog-stereo control=20,0,0.3
#pactl unload-module module-ladspa-sink sink_name=ladspa_output.dyson_compress_1403.dysonCompress label=dysonCompress plugin=dyson_compress_1403 master=ladspa_output.fastLookaheadLimiter control=0,0.5,0.5,0.99

#pactl load-module module-ladspa-sink sink_name=ladspa_output.fastLookaheadLimiter2 label=fastLookaheadLimiter2 plugin=fast_lookahead_limiter_1913 master=alsa_output.pci-0000_05_01.0.analog-stereo control=20,0,0.3
#pactl load-module module-ladspa-sink sink_name=ladspa_output.dyson_compress_1403.dysonCompress2 label=dysonCompress2 plugin=dyson_compress_1403 master=ladspa_output.fastLookaheadLimiter2 control=0,0.5,0.5,0.99
#pactl set-default-sink ladspa_output.dyson_compress_1403.dysonCompress2

pactl load-module module-ladspa-sink sink_name=ladspa_output.fastLookaheadLimiter label=fastLookaheadLimiter plugin=fast_lookahead_limiter_1913 master=alsa_output.pci-0000_05_01.0.analog-stereo control=20,0,0.3
pactl load-module module-ladspa-sink sink_name=ladspa_output.dyson_compress_1403.dysonCompress label=dysonCompress plugin=dyson_compress_1403 master=ladspa_output.fastLookaheadLimiter control=0,0.5,0.5,0.99
#pactl set-default-sink ladspa_output.dyson_compress_1403.dysonCompress
#pactl unload-module module-ladspa-sink sink_name=ladspa_output.fastLookaheadLimiter label=fastLookaheadLimiter plugin=fast_lookahead_limiter_1913 master=alsa_output.pci-0000_05_01.0.analog-stereo control=20,0,0.3
#pactl unload-module module-ladspa-sink sink_name=ladspa_output.dyson_compress_1403.dysonCompress label=dysonCompress plugin=dyson_compress_1403 master=ladspa_output.fastLookaheadLimiter control=0,0.5,0.5,0.99
#pactl unload-module module-ladspa-sink
