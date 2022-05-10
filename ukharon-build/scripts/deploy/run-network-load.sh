#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR"/../registry.sh

BIN_PATH=$1
ARGS="${@:2}"

echo "Starting network-load process"

# Pick the last adapter
MLNX_ADAPTER=$(ibv_devices | tail -n 1 | awk '{ print $1 }')

numactl --cpunodebind=$UKHARON_CPUNODEBIND --membind=$UKHARON_CPUMEMBIND "$BIN_PATH" -d $MLNX_ADAPTER $ARGS
