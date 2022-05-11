#!/bin/bash

source "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/config.sh

export HRD_REGISTRY_IP=$(machine2hostname $REGISTRY_MACHINE)
export DORY_REGISTRY_IP=$(machine2hostname $REGISTRY_MACHINE)

# For maximum performance, do not print logging messages
export SPDLOG_LEVEL=error

UKHARON_RT_MODE=""
if  uname -a | grep "rtcore+heartbeat+nohzfull" -q ; then
    UKHARON_RT_MODE="chrt -f 99"
fi


if [ "$UKHARON_HAVE_SUDO_ACCESS" = true ] ; then
    if [ "$UKHARON_SUDO_ASKS_PASS" = true ] ; then
        export SUDO_ASKPASS="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/pass.py

        UKHARON_SUDO_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -A -E"
        }
        
        UKHARON_CMD_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -A -E $UKHARON_RT_MODE"
        }
    else
        UKHARON_SUDO_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -E"
        }

        UKHARON_CMD_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -E $UKHARON_RT_MODE"
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
