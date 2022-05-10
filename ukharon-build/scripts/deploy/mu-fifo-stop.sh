#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

tmux send-keys -t "ukharon:fifo" C-z
tmux send-keys -t "ukharon:fifo" 'p' ENTER
