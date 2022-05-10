#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

CMD="${@:1}"

tmux send-keys -t "ukharon:acceptor" $CMD ENTER
