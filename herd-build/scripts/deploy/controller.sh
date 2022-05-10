#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

MEMLIB=$1 # nop or unique
BIN_PATH=$2

tmux new-window -t "ukharon" -n "herd-controller" "stdbuf -o L -e L ./run-controller.sh $MEMLIB $BIN_PATH 2>&1 | tee ../logs/controller.txt"
