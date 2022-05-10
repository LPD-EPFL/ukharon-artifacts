#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

MEMLIB=$1 # nop or unique
BIN_PATH=$2
POSTLIST=$3
NUM_THREADS=$3
MACHINE_ID=$4

tmux new-window -t "ukharon" -n "herd-machine" "stdbuf -o L -e L ./run-machine.sh $MEMLIB $BIN_PATH $NUM_THREADS $MACHINE_ID 2>&1 | tee ../logs/machine.txt"
