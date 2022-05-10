#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"/../mu

mkdir compilers

cd compilers
ln -s $(which gcc-7) gcc
ln -s $(which g++-7) g++
ln -s gcc cc
ln -s g++ c++
export PATH="$(pwd)${PATH:+:$PATH}"

cd ..
./build.py distclean
./build.py -c gcc crash-consensus

crash-consensus/demo/using_conan_fully/build.sh gcc-release

cd crash-consensus/libgen
mkdir -p prebuilt-lib/lib
./export.sh gcc-debug && cp -r exported/include prebuilt-lib && mkdir prebuilt-lib/lib/debug && cp exported/libcrashconsensus.so prebuilt-lib/lib/debug
./export.sh gcc-minsizerel && mkdir prebuilt-lib/lib/minsizerel && cp exported/libcrashconsensus.so prebuilt-lib/lib/minsizerel
./export.sh gcc-release && mkdir prebuilt-lib/lib/release && cp exported/libcrashconsensus.so prebuilt-lib/lib/release
./export.sh gcc-relwithdebinfo && mkdir prebuilt-lib/lib/relwithdebinfo && cp exported/libcrashconsensus.so prebuilt-lib/lib/relwithdebinfo
