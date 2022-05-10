#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR"/../registry.sh

BIN_PATH=$1
ARGS="${@:2}"

echo "Starting memory-load process"
numactl --membind=$UKHARON_CPUMEMBIND "$BIN_PATH" $ARGS
