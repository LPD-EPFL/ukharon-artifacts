#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"/../rdma_bench/libhrd/
./do.sh

export LIBRARY_PATH="$SCRIPT_DIR/../membership/nop${LIBRARY_PATH:+:$LIBRARY_PATH}"

cd "$SCRIPT_DIR"/../rdma_bench/herd/

for wrk in {1..6}; do
  sed -E -i "s/#define\ NUM_WORKERS\ .+/#define\ NUM_WORKERS\ $wrk/g" main.h
  ./do.sh
  mv main ../../binaries/herd_w$wrk
done

