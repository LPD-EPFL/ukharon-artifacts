#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

BIN_PATH=$1
ARGS="${@:2}"

#tmux new-window -t "ukharon" -n "fifo"  "stdbuf -o L -e L ./run-mu-fifo.sh $BIN_PATH $ARGS 2>&1 | tee ../logs/mu-fifo.txt"
tmux new-window -t "ukharon" -n "fifo"  "./run-mu-fifo.sh $BIN_PATH $ARGS"
