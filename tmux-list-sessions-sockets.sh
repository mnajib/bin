#!/usr/bin/env bash

ps auxwww | grep -i tmux
echo
lsof -U | grep -i tmux
