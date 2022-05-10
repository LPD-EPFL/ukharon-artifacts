#!/bin/bash

source "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/config.sh

export HRD_REGISTRY_IP=$(machine2hostname $REGISTRY_MACHINE)
export DORY_REGISTRY_IP=$(machine2hostname $REGISTRY_MACHINE)

# TODO: Remove the `LD_LIBRARY_PATH=$LD_LIBRARY_PATH` from the two lines below

if [ "$UKHARON_HAVE_SUDO_ACCESS" = true ] ; then
    if [ "$UKHARON_SUDO_ASKS_PASS" = true ] ; then
        export SUDO_ASKPASS="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/pass.py

        UKHARON_SUDO_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -A -E"
        }
        
        UKHARON_CMD_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -A -E chrt -f 99"
        }
    else
        UKHARON_SUDO_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -E"
        }

        UKHARON_CMD_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -E chrt -f 99"
        }
    fi
else
    UKHARON_SUDO_PREFIX () {
        echo ""
    }
    
    UKHARON_CMD_PREFIX () {
        echo ""
    }
fi
