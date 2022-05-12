#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

tmux new-session -d -s "ukharon" &>/dev/null || true
tmux new-window -t "ukharon" -n "memc" "LD_PRELOAD=$SCRIPT_DIR/libreparent.so memcached -vv"
