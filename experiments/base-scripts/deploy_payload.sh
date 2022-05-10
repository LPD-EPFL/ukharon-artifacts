#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source config.sh

M="$1"
MDIR=${M}dir

MACHINE="${!M}" 
MACHINEDIR="${!MDIR}" 

ssh -o LogLevel=QUIET -t $MACHINE "cd $ROOT_DIR/ukharon_experiment/$MACHINEDIR && unzip -d deployment payload.zip"
ssh -o LogLevel=QUIET -t $MACHINE "cd $ROOT_DIR/ukharon_experiment/$MACHINEDIR && gcc -shared -o libreparent.so -fPIC reparent.c"
