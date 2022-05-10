#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

clear_processes

send_payload "$SCRIPT_DIR"/payload.zip

# Dynamic HERD GET
./dynamic_herd_helper.sh get majority
reset_processes

# Dynamic HERD PUT
./dynamic_herd_helper.sh put majority

clear_processes