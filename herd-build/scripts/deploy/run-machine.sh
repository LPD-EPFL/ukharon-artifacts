#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR"/../registry.sh

MEMLIB=$1
BIN_PATH=$2
NUM_THREADS=$3
MACHINE_ID=$4

export LD_LIBRARY_PATH="$SCRIPT_DIR/membership/$MEMLIB${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

echo "Running $NUM_THREADS client threads"
numactl --cpunodebind=$UKHARON_CPUNODEBIND --membind=$UKHARON_CPUMEMBIND "$BIN_PATH" \
	--num-threads "$NUM_THREADS" \
	--base-port-index 0 \
	--num-server-ports 1 \
	--num-client-ports 1 \
	--is-client 1 \
	--update-percentage 5 \
	--machine-id "$MACHINE_ID"
