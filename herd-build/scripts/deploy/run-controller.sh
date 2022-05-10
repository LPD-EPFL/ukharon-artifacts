#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR"/../registry.sh

"$SCRIPT_DIR"/rm-shm.sh || true

MEMLIB=$1
BIN_PATH=$2

export LD_LIBRARY_PATH="$SCRIPT_DIR/membership/$MEMLIB${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

echo "Starting master process"
numactl --cpunodebind=$UKHARON_CPUNODEBIND --membind=$UKHARON_CPUMEMBIND "$BIN_PATH" \
	--master 1 \
	--base-port-index 0 \
	--num-server-ports 1
