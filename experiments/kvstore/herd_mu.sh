#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

clear_processes

send_payload "$SCRIPT_DIR"/payload.zip

# HERD+Mu GET
./herd_mu_helper.sh get
reset_processes

# HERD+Mu PUT
./herd_mu_helper.sh put

# uKharon-KV failover without cache
# The number of iterations is just a demo.
# Run 1000 iterations for robust results
for i in {1..1}; do
  ./herd_mu_helper.sh put --failover
  reset_processes
  grep "Time to switch (us)" logs/herd_mu/latency_put_failover/m4/logs/herd-client.txt >> logs/herd_mu/put_failover.txt
done

clear_processes
