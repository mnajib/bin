#!/usr/bin/env bash

pgrep -a firefox | awk '{print $1}' | xargs kill
