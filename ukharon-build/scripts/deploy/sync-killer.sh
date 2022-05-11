#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

BIN_PATH=$1
WINDOW=$2
ARGS="${@:3}"

sleep 3

PID=$(tmux capture-pane -t ukharon:$WINDOW -pS -1000 | grep -Po "PID\\d+PID" | sed -r 's/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/')

tmux new-window -t "ukharon" -n "sync-killer" "stdbuf -o L -e L ./run-sync-killer.sh $BIN_PATH $ARGS -p $PID 2>&1 | tee ../logs/sync-killer.txt"
