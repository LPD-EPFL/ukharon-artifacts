#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source config.sh

M="$1"
PAYLOAD="$2"
MDIR=${M}dir

MACHINE="${!M}" 
MACHINEDIR="${!MDIR}" 

scp "$PAYLOAD" $MACHINE:$ROOT_DIR/ukharon_experiment/$MACHINEDIR
scp -p "$SCRIPT_DIR"/memc.sh $MACHINE:$ROOT_DIR/ukharon_experiment/$MACHINEDIR
scp -p "$SCRIPT_DIR"/config.sh $MACHINE:$ROOT_DIR/ukharon_experiment/$MACHINEDIR
scp -p "$SCRIPT_DIR"/registry.sh $MACHINE:$ROOT_DIR/ukharon_experiment/$MACHINEDIR
scp -p "$SCRIPT_DIR"/reparent.c $MACHINE:$ROOT_DIR/ukharon_experiment/$MACHINEDIR

if [ "$UKHARON_HAVE_SUDO_ACCESS" = true ] ; then
    if [ "$UKHARON_SUDO_ASKS_PASS" = true ] ; then
cat << EOF > pass.py
#!/usr/bin/env python3
print("$UKHARON_SUDO_PASS")
EOF
chmod +x pass.py
scp -p "$SCRIPT_DIR"/pass.py $MACHINE:$ROOT_DIR/ukharon_experiment/$MACHINEDIR
    fi
fi
