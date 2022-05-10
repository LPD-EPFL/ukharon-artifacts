#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

BIN_PATH=$1
ARGS="${@:2}"

tmux new-window -t "ukharon" -n "herd-client" "stdbuf -o L -e L ./run-herd-client.sh $BIN_PATH $ARGS 2>&1 | tee ../logs/herd-client.txt"
