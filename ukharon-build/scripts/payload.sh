#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"/..

rm -rf payload.zip
zip -r payload.zip binaries/
zip -urj payload.zip scripts/deploy/*
