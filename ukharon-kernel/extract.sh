#!/bin/bash

# Change the current working directory to the location of the present file
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker run --rm --mount source=ukharon_kernel_builder,target=/app ubuntu cat /app/kernel_debs.tar > ukharon_kernel_debs.tar
