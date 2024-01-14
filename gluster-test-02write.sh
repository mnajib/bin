#!/bin/bash

#SESSION=$USER
#SESSION=0
#SESSION=gluster

#MOUNTPOINT1="/rhev/data-center/mnt/gluster.mrt\:_engineSharedStor/d00630c5-829d-42cc-8105-34bc20c8d984/engineSharedStor-rwtest.log"
MOUNTPOINT1='/rhev/data-center/mnt/gluster.mrt:_engineSharedStor/d00630c5-829d-42cc-8105-34bc20c8d984/engineSharedStor-rwtest.log'
MOUNTPOINT2='/rhev/data-center/mnt/glusterSD/gluster.mrt:_ovirtSharedStor/ovirtSharedStor-rwtest.log'
MOUNTPOINT3='/rhev/data-center/mnt/glusterSD/gluster.mrt:_ovirtSharedStor2/ovirtSharedStor2-rwtest.log'

#sessionid=gluster
#sessionid=0
#windowid=1
#paneid=1

#volumename=engineSharedStor
#volumename2=ovirtSharedStor
#volumename3=ovirtSharedStor2

#watch gluster volume status $volumename &
#while true; do date >> $MOUNTPOINT1; sleep 1; done
#while true; do date >> $MOUNTPOINT1; sleep 1; done &
#tmux select-pane -t .1
#while true; do date >> $MOUNTPOINT1; sleep 1; done &
#echo "while true; do date >> $MOUNTPOINT1; sleep 1; done"
#
# working:
tmux split-window -v -t .1 -p 75 "while true; do date >> $MOUNTPOINT2; sleep 1; done"
tmux split-window -v -t .2 -p 66 "while true; do date >> $MOUNTPOINT2; sleep 1; done"
tmux split-window -v -t .3 -p 50 "while true; do date >> $MOUNTPOINT3; sleep 1; done"
#
# test:
#tmux split-window -v -t .1 -p 75
#tmux select-pane -t .1
#echo "while true; do date >> $MOUNTPOINT1; sleep 1; done"
#tmux split-window -v -t .2 -p 66
#tmux select-pane -t .2
#echo "while true; do date >> $MOUNTPOINT2; sleep 1; done"
#tmux split-window -v -t .3 -p 50
#tmux select-pane -t .3
#echo "while true; do date >> $MOUNTPOINT3; sleep 1; done"
#
#tmux select-pane -t .1

#even-horizontal
#even-vertical

#tmux list-windows

#tmux select-window -t :+2
#tmux select-window -t :1
#tmux select-pane -t 0:1.1
#tmux select-pane -t .1

#tmux split-window -h -t .1 -p 50 "watch gluster volume heal $volumename info"
#tmux split-window -h -t .2 -p 50 "watch gluster volume heal $volumename2 info"
#tmux split-window -h -t .3 -p 50 "watch gluster volume heal $volumename3 info"

## Setup a window for tailing log files
#tmux new-window -t $SESSION:1 -n 'Logs'
#tmux split-window -h
#tmux select-pane -t 0
#tmux send-keys "tail -f /vagrant/maximus.log" C-m
#tmux select-pane -t 1
#tmux send-keys "tail -f /vagrant/maximus-worker.log" C-m
#tmux split-window -v
#tmux resize-pane -D 20
#tmux send-keys "tail -f /vagrant/maximus-mojo.log" C-m
## Setup a CoffeeScript compiler/watchdog pane
#tmux select-pane -t 0
#tmux split-window -v
#tmux resize-pane -D 20
#tmux send-keys "coffee -o /vagrant/root/static/js/ -cw /vagrant/root/coffee/" C-m

# Setup a window for test gluster write test
#tmux has-session -t $SESSION
#if [ $? != 0 ]
#then
#  tmux -2 new-session -d -s $SESSION
#else
#  # select session $SESSION
#  #tmux select-session -t $SESSION:1 # XXX: ???
#fi

#tmux select-window -t $SESSION:1
#tmux split-window -v
#tmux select-pane -t 0
#tmux send-keys "while true; do date >>  $MOUNTPOINT1; sleep 1; done" C-m

# Setup a window for test gluster read test
#l -F /rhev/data-center/mnt/gluster.mrt\:_engineSharedStor/d00630c5-829d-42cc-8105-34bc20c8d984/engineSharedStor-rwtest.log
#tmux select-window -t $SESSION:1
#tmux select-pane -t 1
#tmux send-keys "tail -F $MOUNTPOINT1" C-m

## Setup a MySQL window
#tmux new-window -t $SESSION:2 -n 'MySQL' 'mysql -uroot'

## Set default window
#tmux select-window -t $SESSION:1

## Attach to session
#tmux -2 attach-session -t $SESSION

