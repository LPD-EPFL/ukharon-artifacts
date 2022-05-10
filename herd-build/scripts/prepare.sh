#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"

patch -p1 -d ../rdma_bench < ../patches/1-pick_last_dev.patch
patch -p1 -d ../rdma_bench < ../patches/2-add_call_isactive.patch

cp ../../ukharon-build/ukharon/membership/libgen/src/membership.h ../rdma_bench/herd
cp -r ../../ukharon-build/ukharon/membership/libgen/build/lib/* ../membership/

cp ../../ukharon-build/ukharon/membership/build/bin/membership_acceptor ../binaries
cp ../../ukharon-build/ukharon/membership/build/bin/membership_cache ../binaries
