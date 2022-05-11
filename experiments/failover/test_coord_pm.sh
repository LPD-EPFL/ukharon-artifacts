#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

# parse params
deadbeat_on=false

while [[ "$#" > 0 ]]; do case $1 in
  -c|--cache) majority_cache="cache"; shift;;
  -m|--majority) majority_cache="maj"; shift;;
  -d|--deadbeat) deadbeat_on=true;shift;;
  *) echo "Unknown parameter passed: $1"; shift; shift;;
esac; done

if [ -z "$majority_cache" ]; then echo "Specify -c or -m"; exit 1; fi;

echo "Running with deadbeat mode = $deadbeat_on and Majority/Cache mode = $majority_cache"

#############################################
if "$deadbeat_on" ; then
  heartbeat_str="deadbeat"
  heartbeat=""
else
  heartbeat_str="nodeadbeat"
  heartbeat="--no-deadbeat"
fi

ACCEPTOR1_ARGS="-p 1 -a 1 -a 2 -a 3 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"
ACCEPTOR2_ARGS="-p 2 -a 1 -a 2 -a 3 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"
ACCEPTOR3_ARGS="-p 3 -a 1 -a 2 -a 3 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"

SYNCKILLER_ARGS="-m $UKHARON_SYNCKILLERMCGROUP"

MEMBER_ARGS="-p 5 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"

CACHE_ARGS="-p 4 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"

FAILOVER_ARGS="-p 6 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP -s $UKHARON_SYNCKILLERMCGROUP -w 2"

# send_payload "$SCRIPT_DIR"/payload.zip
reset_processes

ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

# Acceptors
ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor.sh binaries/membership_acceptor $ACCEPTOR1_ARGS $heartbeat"
ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/sync-killer.sh binaries/sync_killer acceptor $SYNCKILLER_ARGS"

ssh -o LogLevel=QUIET -t $(machine2ssh machine5) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine5)/deployment/acceptor.sh binaries/membership_acceptor $ACCEPTOR2_ARGS"
ssh -o LogLevel=QUIET -t $(machine2ssh machine6) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine6)/deployment/acceptor.sh binaries/membership_acceptor $ACCEPTOR3_ARGS"


# Member with sync-killer
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/member.sh binaries/membership_member $MEMBER_ARGS $heartbeat"
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/sync-killer.sh binaries/sync_killer member $SYNCKILLER_ARGS"


if [[ "$majority_cache" == "cache" ]] ; then
  ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/cache.sh binaries/membership_cache $CACHE_ARGS $heartbeat"
fi

# Failover test
ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/failover.sh binaries/test_${majority_cache}_coordinated_failures $FAILOVER_ARGS"

# Running the test sequence
if [[ "$majority_cache" == "cache" ]] ; then
  sleep 2
  ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor-join.sh C4"
fi

sleep 2
ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor-join.sh A5"

sleep 3
ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor-join.sh A6"

sleep 5

ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/sync-killer-emit.sh binaries/sync_killer -m $UKHARON_SYNCKILLERMCGROUP"


gather_results "$SCRIPT_DIR"/logs/failover_app_coord/latency_${majority_cache}_${heartbeat_str}