#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR"/../registry.sh

BIN_PATH=$1
ARGS="${@:2}"

export LD_LIBRARY_PATH="$SCRIPT_DIR/binaries/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

echo "Starting herd-server process"
$(UKHARON_CMD_PREFIX) numactl --cpunodebind=$UKHARON_CPUNODEBIND --membind=$UKHARON_CPUMEMBIND "$BIN_PATH" $ARGS
