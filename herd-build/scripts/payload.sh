#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"/..

rm -rf payload.zip
zip -r payload.zip binaries/ membership/
zip -urj payload.zip scripts/deploy/*
zip -urj payload.zip ../ukharon-build/scripts/deploy/*
zip -urj payload.zip ../ukharon-build/ukharon/membership/build/bin/membership_acceptor
zip -urj payload.zip ../ukharon-build/ukharon/membership/build/bin/membership_cache
