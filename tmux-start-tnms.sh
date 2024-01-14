#!/bin/sh

#tmux new-session -d -s foo 'exec pfoo'
#tmux send-keys 'bundle exec thin start' 'C-m'
#tmux rename-window 'Foo'
#tmux select-window -t foo:0
#tmux split-window -h 'exec pfoo'
#tmux send-keys 'bundle exec compass watch' 'C-m'
#tmux split-window -v -t 0 'exec pfoo'
#tmux send-keys 'rake ts:start' 'C-m'
#tmux split-window -v -t 1 'exec pfoo'
#tmux -2 attach-session -t foo

#tmux detach
tmux new-session -d -s tnms
tmux rename-window 'node1'
tmux new-window
tmux rename-window 'node2'
tmux new-window
tmux rename-window 'node3'
tmux new-window
tmux rename-window 'engine'
tmux new-window
tmux rename-window 'tnms'
tmux new-window
tmux rename-window 'ping'
tmux -2 attach-session -t tnms
