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
  ./failover_app_coord_helper.sh -m -d
  reset_processes
  grep "s->a" logs/failover_app_coord/latency_maj_deadbeat/m4/logs/failover.txt >> logs/failover_app_coord/latency_maj_deadbeat.txt
done

for i in $(seq 1 $ITER); do
  ./failover_app_coord_helper.sh -m
  reset_processes
  grep "s->a" logs/failover_app_coord/latency_maj_nodeadbeat/m4/logs/failover.txt >> logs/failover_app_coord/latency_maj_nodeadbeat.txt
done

for i in $(seq 1 $ITER); do
  ./failover_app_coord_helper.sh -c -d
  reset_processes
  grep "s->a" logs/failover_app_coord/latency_cache_deadbeat/m4/logs/failover.txt >> logs/failover_app_coord/latency_cache_deadbeat.txt
done

for i in $(seq 1 $ITER); do
  ./failover_app_coord_helper.sh -c
  reset_processes
  grep "s->a" logs/failover_app_coord/latency_cache_nodeadbeat/m4/logs/failover.txt >> logs/failover_app_coord/latency_cache_nodeadbeat.txt
done

clear_processes
