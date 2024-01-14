import time
import datetime
import os
import subprocess

dura = 0.25 # duration in seconds
freq = 300  # frequency

while True:
##    for d in range(45, 100):
##        for f in range(300, 600):
##            freq = f
            #dura = (200 + d) / 100 # 0.25 to 1.00
##            dura = d/100
                        
            print ("Wake up! ... " + str(freq) + ", " + str(dura))
            #print ("Wake up!")
            os.system('play --no-show-progress --null --channels 1 synth %s sine %f' % ( dura, freq))
            #os.system('play --no-show-progress --null --channels 1 synth %s sine %f' % ( dura, freq))
            #subprocess.call("mpg123 /home/najib/Music/alarm.mp3", shell=True)
            #subprocess.call("mpg123 /mnt/NGREY/DATA/_audio-video/_av.music_videos/alfarabi/SimfoniEvolusi.mp3", shell=True)
            
            #f = f + 30
            time.sleep(1)
##        d = d + 1
