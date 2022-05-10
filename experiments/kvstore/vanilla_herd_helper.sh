#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

operation="$1" # `put`` or `get`
failover="$2" # `--failover` or no argument given

# send_payload "$SCRIPT_DIR"/payload.zip

SRV1_ARGS="-p 1 -c 1 -c 2 -c 3 --skip-proposal"
SRV2_ARGS="-p 2 -c 1 -c 2 -c 3 --skip-proposal"
SRV3_ARGS="-p 3 -c 1 -c 2 -c 3 --skip-proposal"

HERDCLI_ARGS="-p 4 -m 1 -s 2 --load $operation"

reset_processes

ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

# Acceptors
ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/herd-server-mu.sh binaries/herd_server_mu $SRV1_ARGS"
sleep 2
ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/herd-server-mu.sh binaries/herd_server_mu $SRV2_ARGS"
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/herd-server-mu.sh binaries/herd_server_mu $SRV3_ARGS"
sleep 10

ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/herd-client.sh binaries/herd_client_mu $HERDCLI_ARGS"
sleep 60

gather_results "$SCRIPT_DIR"/logs/vanilla_herd/latency_${operation}${failover_str}

# clear_processes