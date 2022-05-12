#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

clear_processes

send_payload "$SCRIPT_DIR"/payload.zip

# The number of iterations is just a demo.
# Replace with the commented code for full results
# for memload in $(seq 0 $(./mem_computation.py -c $UKHARON_MEMSTRESS_CORES --count)); do
#     for netload in 0 30 60 80 100; do
#        for delta in {15..30}; do
for memload in $(./mem_computation.py -c $UKHARON_MEMSTRESS_CORES -n 3 --count 2>/dev/null || echo 0); do
    for netload in 80; do
        for delta in 25; do
            ./stress_helper.sh $delta $netload $memload
            clear_processes
        done
    done
done

clear_processes
