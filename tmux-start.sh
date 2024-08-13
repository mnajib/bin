#!/usr/bin/env bash

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

createNewSession() {
  SESSIONNAME="script"
  tmux has-session -t $SESSIONNAME &> /dev/null

  if [ $? != 0 ]
   then
      tmux new-session -s $SESSIONNAME -n script -d
      #tmux send-keys -t $SESSIONNAME "~/bin/script" C-m
  fi

  tmux attach -t $SESSIONNAME
}

# at vnet

tmux new-session -d -s lnv
tmux rename-window 'jobs'
tmux new-window
tmux rename-window 'root'
#tmux send-keys '/root/bin/tmux-start-root.sh' 'C-m'
tmux new-window
tmux rename-window 'note'

tmux new-session -d -s '@lnv'
tmux rename-window 'tnmsdev'
tmux new-window
tmux rename-window 'bcisdev'

tmux new-session -d -s '@vnet'
tmux rename-window 'gitvnet'
tmux new-window
tmux rename-window 'bugvnet'
tmux new-window
tmux rename-window 'stagvnet'
tmux -2 attach-session -t lnv

