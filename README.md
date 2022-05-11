# Overview
uKharon is a membership service for microsecond applications.

This repository contains the artifacts and instructions needed to reproduce the experiments in the paper.
More precisely, it contains:
* Instructions on how to build and install the custom Linux kernel as well as the failure detection module.
* Instructions on how to build the payloads for the different experiments.
* Instructions on how to launch the experiments and obtain the results.

After running the experiments, you should be able to get the numbers shown in:
* Figure 3: Percentage of timely lease renewal depending on the lease duration, network load and memory load
* Figure 4: Impact of uKharon on HERD's throughput
* Table 2: Failover time upon various failures
* Figure 5: Latency comparison of vanilla HERD, HERD+Mu and uKharon-KV

Our artifacts can be evaluated on either your own hardware or on a live, pre-configured, environment we provide ssh access to.
Importantly, our live environement is not meant to be used by multiple reviewers concurrently and thus requires (human) synchronization on your side

# Getting started

In this introduction section, we will assume that you decided to evaluate our artifacts by using our live environment.
The goal of this section is to let you access our cluster and run the experiments there without having to configure nor compile any artifacts.

## Connecting to the cluster

Our cluster is accessible through an ssh gateway. Connect to our gateway by running:
```bash
ssh -p 2233 user@lpdquatro1.epfl.ch
```

When asked for a password, enter the password provided through HotCRP.

The cluster is comprised of 8 pre-configured machines. You can access any of them by running:
```bash
ssh atc-node{1..8}
```

## Running experiments

The binaries as well as the deployment scripts required to run the experiments were pre-uploaded to the gateway. If, for some reason, you do not trust the payloads, you can rebuild them on one of the cluster's machines by following the instructions in [the detailed instruction section](#detailed-instructions).

### Reproducing Figure 3

### Reproducing Figure 4

### Reproducing Table 2

### Reproducing Figure 5

# Detailed instructions

This section will guide you on how to build, configure, and run all experiments to reproduce the results presented in the paper.

Although we provide detailed instructions, building all dependencies and configuring the experimental machines can be tedious. As we do not expect you to have the hardware and permissions required to deploy our artifcats from scrath, we suggest you:
* follow the instructions to build the artifacts (which do not require specific hardware),
* skip configuration steps,
* upload and run the experiments from our provided gateway as explained in [Getting started](#getting-started)

# Prerequisites
The source code and all experiments were executed using Ubuntu 20.04. Different systems may work, but they have not been tested.

The machines have to have FQDN and open ports: 7000-7100, 11211, 18515

## Apt and pip dependecies
The packages needed to be present in a vanilla Ubuntu 20.04 installation are the following:
```sh
sudo apt-get -y install \
    python3 python3-pip \
    build-essential cmake ninja-build \
    libibverbs-dev memcached libmemcached-dev 

pip3 install --upgrade "conan>=1.47.0"

# halo: Required by conan/invoker/invoker.py to show the compilation output compactly
pip3 install --upgrade pyyaml"<6.0,>=3.11" halo
```

Optionally (to use other functionalities of the build system, e.g., code formatting), you can also install:
```sh
apt-get -y install clang-10 lld-10 clang-format-10 clang-tidy-10 clang-tools-10

# Fix the LLD path
# (If we install `lld` instead of `lld-10`, the following command is not needed)
sudo update-alternatives --install "/usr/bin/ld.lld" "ld.lld" "/usr/bin/ld.lld-10" 20

# pyyaml: Required from clang-tidy
# cmake-format: Required by format.sh
# black: Required by format.sh
pip3 install --upgrade pyyaml"<6.0,>=3.11" cmake-format black halo
```

## Mellanox OFED dependency

# How to build
We assume that all machines have identical configuration, thus you need to:
* build all the necessary binaries in one deployment machine,
* package them and deploy them in all 8 machines.

The building process is long and complex. Follow the instructions in each one of the following sub-directories:
* Compile and boot uKharon's kernel, as explained in [`ukharon-kernel`](ukharon-kernel/).
* Install the Mellanox's OFED driver (in the deployment machines), as explained in [`ukharon-kernel-modules`](ukharon-kernel-modules/).
* Build Mu (in a deployment machine), as explained in [`mu-build`](mu-build/).
* Build uKharon (in a deployment machine), as explained in [`ukharon-build`](ukharon-build/).
* Build HERD (in a deployment machine), as explained in [`herd-build`](herd-build/).

Once you have finished with the above steps, the binaries will be packaged in `payload.zip` files.

# How to deploy
To deploy the various experiments, follow the instructions under [`experiments`](experiments/).
