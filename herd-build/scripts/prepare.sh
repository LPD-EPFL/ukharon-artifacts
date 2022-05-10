#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"/..

git clone https://github.com/efficient/rdma_bench
cd rdma_bench
git checkout a038ec5e2b9f1ac9d4da2fc0044786c82c9ee575
cd ..

patch -p1 -d rdma_bench < patches/1-pick_last_dev.patch
patch -p1 -d rdma_bench < patches/2-add_call_isactive.patch

cp ../ukharon-build/ukharon/membership/libgen/src/membership.h rdma_bench/herd
cp -r ../ukharon-build/binaries/libgen/* membership

cp ../ukharon-build/binaries/membership_acceptor binaries
cp ../ukharon-build/binaries/membership_cache binaries
