#!/usr/bin/env bash

function printTheVars {
  echo "XDG_RUNTIME_DIR: ${XDG_RUNTIME_DIR}"
  echo "TMUX_TMPDIR: ${TMUX_TMPDIR}"
}

printTheVars
export TMUX_TMPDIR="${XDG_RUNTIME_DIR}"
printTheVars
