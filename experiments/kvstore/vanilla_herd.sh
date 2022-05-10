#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

clear_processes

send_payload "$SCRIPT_DIR"/payload.zip

# Vanilla HERD GET
./vanilla_herd_helper.sh get
reset_processes

# Vanilla HERD PUT
./vanilla_herd_helper.sh put

clear_processes
