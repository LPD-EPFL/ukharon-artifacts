#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

BIN_PATH=$1
TMUX_NAME=$2
ARGS="${@:3}"

tmux new-window -t "ukharon" -n "majority-load-$TMUX_NAME" "stdbuf -o L -e L ./run-majority-load.sh $BIN_PATH $ARGS 2>&1 | tee ../logs/majority-load-$TMUX_NAME.txt"

sleep 2
proc_pid=$(tmux capture-pane -t ukharon:majority-load-$TMUX_NAME -pS -1000 | grep -Po "PID\\d+PID" | sed -r 's/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/')

source "$SCRIPT_DIR"/../registry.sh
taskset -a -cp $(cat /sys/devices/system/node/node${UKHARON_CPUNODEBIND}/cpulist) $proc_pid
