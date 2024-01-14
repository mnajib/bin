#!/bin/bash

#sessionid=gluster
#sessionid=0
#windowid=1
#paneid=1

volumename=engineSharedStor
volumename2=ovirtSharedStor
volumename3=ovirtSharedStor2

#watch gluster volume heal $volumename info split-brain&
#tmux split-window -v -t .1 -p 66 "watch gluster volume heal $volumename2 info split-brain"
#tmux split-window -v -t .2 -p 50 "watch gluster volume heal $volumename3 info split-brain"

watch gluster volume heal $volumename info split-brain&
tmux split-window -v -t .1 -p 66 "watch gluster volume heal $volumename2 info split-brain"
tmux split-window -v -t .2 -p 50 "watch gluster volume heal $volumename3 info split-brain"

#tmux select-window -t :+2
#tmux select-window -t :1
#tmux select-pane -t 0:1.1
#tmux select-pane -t .1

tmux split-window -h -t .1 -p 50 "watch gluster volume heal $volumename info"
tmux split-window -h -t .2 -p 50 "watch gluster volume heal $volumename2 info"
tmux split-window -h -t .3 -p 50 "watch gluster volume heal $volumename3 info"
