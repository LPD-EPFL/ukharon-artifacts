#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

clear_processes

send_payload "$SCRIPT_DIR"/payload.zip

# The number of iterations is just a demo.
# Run 1000 iterations for robust results
ITER=1

for i in $(seq 1 $ITER); do
  ./failover_app_leasecache_coord_helper.sh -d
  reset_processes
  grep "s->a" logs/failover_app_leasecache_coord/latency_deadbeat/m7/logs/failover.txt >> logs/failover_app_leasecache_coord/latency_deadbeat.txt
done

for i in $(seq 1 $ITER); do
  ./failover_app_leasecache_coord_helper.sh
  reset_processes
  grep "s->a" logs/failover_app_leasecache_coord/latency_nodeadbeat/m7/logs/failover.txt >> logs/failover_app_leasecache_coord/latency_nodeadbeat.txt
done

clear_processes
