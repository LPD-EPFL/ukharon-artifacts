#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

clear_processes

send_payload "$SCRIPT_DIR"/payload.zip

# uKharon-KV GET
./herd_ukharon_helper.sh get majority
reset_processes

# uKharon-KV PUT
./herd_ukharon_helper.sh put majority
reset_processes

# uKharon-KV failover without cache
# The number of iterations is just a demo.
# Run 1000 iterations for robust results
for i in {1..5}; do
  ./herd_ukharon_helper.sh put majority --failover
  reset_processes
  grep "Time to switch (us)" logs/herd_ukharon/latency_put_majority_failover/m4/logs/herd-client.txt >> logs/herd_ukharon/ukharonkv_failover_without_cache.txt
done

# uKharon-KV failover with cache
# The number of iterations is just a demo.
# Run 1000 iterations for robust results
for i in {1..5}; do
  ./herd_ukharon_helper.sh put cache --failover
  reset_processes
  grep "Time to switch (us)" logs/herd_ukharon/latency_put_cache_failover/m4/logs/herd-client.txt >> logs/herd_ukharon/ukharonkv_failover_with_cache.txt
done

clear_processes