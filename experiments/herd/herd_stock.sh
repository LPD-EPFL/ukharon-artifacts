#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

# The number of iterations is just a demo.
# Replace with the commented code for full results
# for workers in 1 2 3 4 5 6 ; do
#     for postlist in 1 2 3 4 5 6 7 8 ; do
for workers in 5 ; do
    for postlist in 4 ; do
        reset_processes
        ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/controller.sh nop binaries/herd_w${workers}"
        sleep 1
        ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/workers.sh nop binaries/herd_w${workers} $postlist"
        sleep 1
        
        ssh -o LogLevel=QUIET -t $(machine2ssh machine5) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine5)/deployment/machine.sh nop binaries/herd_w${workers} 30 0"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine6) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine6)/deployment/machine.sh nop binaries/herd_w${workers} 30 1"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine7) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine7)/deployment/machine.sh nop binaries/herd_w${workers} 30 2"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine8) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine8)/deployment/machine.sh nop binaries/herd_w${workers} 30 3"
        
        sleep 40
        
        ssh -o LogLevel=QUIET -t $(machine2ssh machine5) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine5)/deployment/machine-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine6) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine6)/deployment/machine-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine7) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine7)/deployment/machine-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine8) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine8)/deployment/machine-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/workers-stop.sh"
        ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/controller-stop.sh"
        
        gather_results "$SCRIPT_DIR"/logs/stock_w${workers}_p${postlist}
        
        clear_processes
    done
done
