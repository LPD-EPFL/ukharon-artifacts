#!/bin/bash

docker run -it --rm --mount source=ukharon_kernel_builder,target=/app ukharon_kernel_builder
#docker run -it --rm --mount source=ukharon_kernel_builder,target=/app ukharon_kernel_builder
#docker run -it --rm --tmpfs /app:exec,mode=777 ukharon_kernel_builder
