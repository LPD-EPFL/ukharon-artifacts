#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

MAJDELTA=$1 # Can be 25, ..., 30
CLIENTS=31
NETWORK_LOAD=$2 # Can be 0, 30, 60, 80, 100
MEMORY_LOAD=$3 # Can be 0, 1, ..., 6

# send_payload "$SCRIPT_DIR"/payload.zip

reset_processes

ACCEPTOR1_ARGS="-p 1 -a 1 -a 2 -a 3 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"
ACCEPTOR2_ARGS="-p 2 -a 1 -a 2 -a 3 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"
ACCEPTOR3_ARGS="-p 3 -a 1 -a 2 -a 3 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"

LOADER_ARGS="-m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"
RENEWER_ARGS="-p 10 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"

NETWORK_LOAD_SRV_ARGS="" # --disable_pcie_relaxed 
NETWORK_LOAD_CLI_ARGS="-F -s 65536 -D 360" # --disable_pcie_relaxed 

ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

# Start the caches first to pick up the initial membership
for i in $(seq 1 $CLIENTS); do
    id_machine=($(./load_computation.py -x $CLIENTS -m machine{5..8} -i 20 -c $((i-1))))
    ssh -o LogLevel=QUIET -t $(machine2ssh ${id_machine[1]}) "$ROOT_DIR/ukharon_experiment/$(machine2dir ${id_machine[1]})/deployment/majority-load.sh binaries/stress/membership_cache_m${MAJDELTA} ${id_machine[0]} -p ${id_machine[0]} $LOADER_ARGS"
done
sleep 5

# Start the acceptors
ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor.sh binaries/stress/membership_acceptor_m${MAJDELTA} $ACCEPTOR1_ARGS"
ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/acceptor.sh binaries/stress/membership_acceptor_m${MAJDELTA} $ACCEPTOR2_ARGS"
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/acceptor.sh binaries/stress/membership_acceptor_m${MAJDELTA} $ACCEPTOR3_ARGS"

if [ $NETWORK_LOAD -gt 0 ] ; then
    echo "Starting the background network load"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/network-load.sh ib_write_bw $NETWORK_LOAD_ARGS"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/network-load.sh ib_write_bw $NETWORK_LOAD_ARGS"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/network-load.sh ib_write_bw $NETWORK_LOAD_ARGS"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/network-load.sh ib_write_bw $NETWORK_LOAD_ARGS"
    sleep 5

    ssh -o LogLevel=QUIET -t $(machine2ssh machine5) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine5)/deployment/network-load.sh ib_write_bw $NETWORK_LOAD_CLI_ARGS --rate_limit $NETWORK_LOAD $(machine2hostname machine1)"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine6) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine6)/deployment/network-load.sh ib_write_bw $NETWORK_LOAD_CLI_ARGS --rate_limit $NETWORK_LOAD $(machine2hostname machine2)"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine7) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine7)/deployment/network-load.sh ib_write_bw $NETWORK_LOAD_CLI_ARGS --rate_limit $NETWORK_LOAD $(machine2hostname machine3)"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine8) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine8)/deployment/network-load.sh ib_write_bw $NETWORK_LOAD_CLI_ARGS --rate_limit $NETWORK_LOAD $(machine2hostname machine4)"
    sleep 5
fi

if [ $MEMORY_LOAD -gt 0 ] ; then
    # Note: To estimate the memory bandwidth of your system, use stress-ng and/or https://zsmith.co/bandwidth.php
    echo "Starting the memory load"
    MEMORY_LOAD_ARGS="--taskset $(./mem_computation.py -c $UKHARON_MEMSTRESS_CORES -n $MEMORY_LOAD) --memrate $MEMORY_LOAD --timeout 360s"

    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/memory-load.sh stress-ng $MEMORY_LOAD_ARGS"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/memory-load.sh stress-ng $MEMORY_LOAD_ARGS"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/memory-load.sh stress-ng $MEMORY_LOAD_ARGS"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/memory-load.sh stress-ng $MEMORY_LOAD_ARGS"
    sleep 5
fi

ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/active-renewer.sh binaries/stress/test_maj_inactivity_stable_view_${MAJDELTA} $RENEWER_ARGS"
sleep 5

ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor-join.sh A10"
sleep 60
ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor-join.sh KP- 10"
ssh -t delta1 "tmux send-keys -t herd KP- 10 ENTER"
sleep 3

gather_results "$SCRIPT_DIR"/logs/inactivity_maj${MAJDELTA}_net${NETWORK_LOAD}_mem${MEMORY_LOAD}

# clear_processes
