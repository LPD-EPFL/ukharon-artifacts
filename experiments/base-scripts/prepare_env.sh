#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source config.sh

M="$1"
MDIR=${M}dir

MACHINE="${!M}" 
MACHINEDIR="${!MDIR}" 

ssh -o LogLevel=QUIET -t $MACHINE \
    "rm -rf $ROOT_DIR/ukharon_experiment/$MACHINEDIR && \
     mkdir -p $ROOT_DIR/ukharon_experiment/$MACHINEDIR/logs"
