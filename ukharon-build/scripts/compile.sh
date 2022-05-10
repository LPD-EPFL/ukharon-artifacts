#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"/../ukharon

./build.py distclean

git restore -- membership/src/default-config.hpp

while true; do
	read -p "Did you appropriately configure the core multicast groups in $(realpath membership/libgen/src/config.hpp)?[y/n] " yn
    case $yn in
        [Yy]* ) echo "Great! Continuing with building"; break;;
        [Nn]* ) echo "Please, configure the broadcast groups before continuing"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
	read -p "Did you appropriately configure the core pinning in $(realpath demo/src/herd/mu/config.hpp)?[y/n] " yn
    case $yn in
        [Yy]* ) echo "Great! Continuing with building"; break;;
        [Nn]* ) echo "Please, configure the core-pinning before continuing"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
	read -p "Did you appropriately configure the core pinning in $(realpath membership/src/default-config.hpp)?[y/n] " yn
    case $yn in
        [Yy]* ) echo "Great! Continuing with building"; break;;
        [Nn]* ) echo "Please, configure the core-pinning before continuing"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

./build.py membership
./build.py demo

cd membership/libgen
./conanfile.py --build-locally
cd ../../
cp -r membership/libgen/build/lib ../binaries/libgen

mkdir -p ../binaries/lib && cp crash-consensus/src/lib/release/*.so ../binaries/lib
cp ../../mu-build/mu/crash-consensus/demo/using_conan_fully/build/bin/fifo ../binaries
cp membership/build/bin/* ../binaries
cp demo/build/bin/herd_* ../binaries
cp demo/build/bin/sync_killer ../binaries

mkdir -p ../binaries/stress
cd membership
./conanfile.py --build-locally
for majdelta in {15..30}; do
  sed -E -i "s/DeltaMajority\(.+\)/DeltaMajority\($majdelta\)/g" src/default-config.hpp
  ninja -C build membership_acceptor membership_cache test_maj_inactivity_stable_view
  cp build/bin/membership_acceptor ../../binaries/stress/membership_acceptor_m$majdelta
  cp build/bin/membership_cache ../../binaries/stress/membership_cache_m$majdelta
  cp build/bin/test_maj_inactivity_stable_view ../../binaries/stress/test_maj_inactivity_stable_view_$majdelta
done

cd ..
./build.py distclean
