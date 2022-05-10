#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR"/../registry.sh

MEMLIB=$1
BIN_PATH=$2
POSTLIST=$3

export LD_LIBRARY_PATH="$SCRIPT_DIR/membership/$MEMLIB${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

echo "Starting worker threads"
numactl --cpunodebind=$UKHARON_CPUNODEBIND --membind=$UKHARON_CPUMEMBIND "$BIN_PATH" \
	--is-client 0 \
	--base-port-index 0 \
	--num-server-ports 1 \
	--postlist "$POSTLIST"
