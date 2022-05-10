#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source config.sh

M="$1"
DESTDIR="$2"
MDIR=${M}dir

MACHINE="${!M}" 
MACHINEDIR="${!MDIR}" 

mkdir -p "$DESTDIR"/"$MACHINEDIR"

scp -r $MACHINE:$ROOT_DIR/ukharon_experiment/$MACHINEDIR/logs "$DESTDIR"/"$MACHINEDIR"
