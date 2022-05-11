#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

BIN_PATH=$1
ARGS="${@:2}"

tmux new-window -t "ukharon" -n "failover-test" "stdbuf -o L -e L ./run-failover.sh $BIN_PATH $ARGS 2>&1 | tee ../logs/failover.txt"
