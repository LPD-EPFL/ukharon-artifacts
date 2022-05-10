#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

operation="$1" # `put`` or `get`
access="$2" # `majority` or `cache`

# send_payload "$SCRIPT_DIR"/payload.zip

ACCEPTOR1_ARGS="-p 1 -a 1 -a 2 -a 3 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"
ACCEPTOR2_ARGS="-p 2 -a 1 -a 2 -a 3 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"
ACCEPTOR3_ARGS="-p 3 -a 1 -a 2 -a 3 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"

HERDSRV1_ARGS="-p 5 -m 5 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP --access $access"
HERDSRV2_ARGS="-p 6 -m 6 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP --access $access"
HERDCLI_ARGS="-p 7 -m 5 -s 6 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP --load $operation"

reset_processes

ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

if [ "$access" = "majority" ]; then
  firstacceptormachine="machine1"
else
  firstacceptormachine="machine7"
fi

# Acceptors
ssh -o LogLevel=QUIET -t $(machine2ssh $firstacceptormachine) "$ROOT_DIR/ukharon_experiment/$(machine2dir $firstacceptormachine)/deployment/acceptor.sh binaries/membership_acceptor $ACCEPTOR1_ARGS"
ssh -o LogLevel=QUIET -t $(machine2ssh machine5) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine5)/deployment/acceptor.sh binaries/membership_acceptor $ACCEPTOR2_ARGS"
ssh -o LogLevel=QUIET -t $(machine2ssh machine6) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine6)/deployment/acceptor.sh binaries/membership_acceptor $ACCEPTOR3_ARGS"
sleep 3

if [ "$access" = "cache" ]; then
  ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/cache.sh binaries/membership_cache $CACHE_ARGS"
  sleep 2
  
  ssh -o LogLevel=QUIET -t $(machine2ssh $firstacceptormachine) "$ROOT_DIR/ukharon_experiment/$(machine2dir $firstacceptormachine)/deployment/acceptor-join.sh C4"
fi

# Herd
ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/herd-server.sh binaries/herd_server_mukharon $HERDSRV1_ARGS"
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/herd-server.sh binaries/herd_server_mukharon $HERDSRV2_ARGS"
sleep 2

ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/herd-client.sh binaries/herd_client_mukharon $HERDCLI_ARGS"
sleep 2

# Join
ssh -o LogLevel=QUIET -t $(machine2ssh $firstacceptormachine) "$ROOT_DIR/ukharon_experiment/$(machine2dir $firstacceptormachine)/deployment/acceptor-join.sh A5"
sleep 1

ssh -o LogLevel=QUIET -t $(machine2ssh $firstacceptormachine) "$ROOT_DIR/ukharon_experiment/$(machine2dir $firstacceptormachine)/deployment/acceptor-join.sh A6"
sleep 2

sleep 60

ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/sync-killer.sh binaries/sync_killer -m $UKHARON_MCGROUP"
sleep 2

gather_results "$SCRIPT_DIR"/logs/dynamic_herd/latency_${operation}_${access}

# clear_processes