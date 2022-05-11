#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

ACCEPTOR1_ARGS="-p 1 -a 1 -a 2 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"
ACCEPTOR2_ARGS="-p 2 -a 1 -a 2 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"
CACHE_ARGS="-p 5 -m $UKHARON_MCGROUP -k $UKHARON_KERNELMCGROUP"

for workers in 1 2 3 4 5 6 ; do
    for postlist in 1 2 3 4 5 6 7 8 ; do
        reset_processes
        ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

        ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor.sh binaries/membership_acceptor $ACCEPTOR1_ARGS"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/acceptor.sh binaries/membership_acceptor $ACCEPTOR2_ARGS"
        sleep 3

        ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/cache.sh binaries/membership_cache $CACHE_ARGS"
        sleep 1
        
        # Adding cache to membership
        ssh -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor-join.sh C5"
        sleep 1

        ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/controller.sh unique binaries/herd_w${workers}"
        sleep 1
        ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/workers.sh unique binaries/herd_w${workers} $postlist"
	sleep 3

        # Adding herd-worker to membership
        ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor-join.sh A10"
        sleep 3

        ssh -o LogLevel=QUIET -t $(machine2ssh machine5) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine5)/deployment/machine.sh unique binaries/herd_w${workers} 30 0"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine6) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine6)/deployment/machine.sh unique binaries/herd_w${workers} 30 1"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine7) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine7)/deployment/machine.sh unique binaries/herd_w${workers} 30 2"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine8) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine8)/deployment/machine.sh unique binaries/herd_w${workers} 30 3"
        
        sleep 40
        
        ssh -o LogLevel=QUIET -t $(machine2ssh machine5) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine5)/deployment/machine-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine6) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine6)/deployment/machine-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine7) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine7)/deployment/machine-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine8) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine8)/deployment/machine-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/workers-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/controller-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/acceptor-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/acceptor-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/cache-stop.sh"
        
        gather_results "$SCRIPT_DIR"/logs/isactive_w${workers}_p${postlist}

        clear_processes
    done
done
