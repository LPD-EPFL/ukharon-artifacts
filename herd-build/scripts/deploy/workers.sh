#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

MEMLIB=$1 # nop or unique
BIN_PATH=$2
POSTLIST=$3

tmux new-window -t "ukharon" -n "herd-worker" "stdbuf -o L -e L ./run-workers.sh $MEMLIB $BIN_PATH $POSTLIST 2>&1 | tee ../logs/workers.txt"
