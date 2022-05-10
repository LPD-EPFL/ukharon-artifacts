#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"/..

git clone https://github.com/LPD-EPFL/ukharon
cd ukharon
cp -r ../../mu-build/mu/crash-consensus/libgen/prebuilt-lib/* crash-consensus/src
