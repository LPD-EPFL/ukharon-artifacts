# Overview
uKharon is a membership service for microsecond applications.

This repository contains the artifacts and instructions needed to reproduce the experiments in the ATC submission.
More precisely, it contains:
* Instructions on how to build and install the custom Linux kernel as well as the failure detection module.
* Instructions on how to build the payloads for the different experiments.
* Instructions on how to launch the experiments and obtain the results.

By running the experiments, you should be able to reproduce the numbers shown in:
* **Figure 3**: Percentage of timely lease renewal depending on the lease duration, network load and memory load
* **Figure 4**: Impact of uKharon on HERD's throughput
* **Table 2**: Failover time upon various failures
* **Figure 5**: Latency comparison of vanilla HERD, HERD+Mu and uKharon-KV

Our artifacts can either be evaluated on your own hardware or on a live, pre-configured, environment we provide an ssh access to.

**Importantly, our live environement is not meant to be used by multiple reviewers concurrently and thus requires (human) synchronization on your side.**

We do not provide the scripts that generate the figures themselves. 

# Getting started

In this introductory section, we explain how to evaluate our artifacts using the live environment we provide.
More precisely, the goal of this section is to let you access our cluster and run the experiments without having to configure or compile any artifacts.

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

## Running the experiments

The binaries as well as the deployment scripts required to run the experiments were pre-uploaded to the gateway. If, for some reason, you do not trust the payloads, you can rebuild them on one of the cluster's machines by following [the detailed instructions](#detailed-instructions).

### Reproducing Figure 3

From the gateway, run:
```sh
experiments/stress/stress.sh
```
Find the generated information under logs/inactivity_maj*_net*_mem*/m4/logs/active-renewer.txt.

> Note: Edit stress.sh to run various configurations.

### Reproducing Figure 4

#### Evaluating stock Herd
From the gateway, run:
```sh
experiments/herd/herd_stock.sh
```
Find the generated information under `experiments/herd/logs/stock_*/m1/logs/workers.txt`.
> Note: Running the full experiments takes ~2h. By default, only a subset of the parameter space is evaluated. Edit `herd_stock.sh` to run more configurations.

**TODO: how to interpret the results**

#### Evaluating uKharon's overhead
From the gateway, run:
```sh
experiments/herd/herd_isactive.sh
```
Find the generated information under `experiments/herd/logs/herd_isactive_*/m4/logs/workers.txt`.
> Note: Running the full experiments takes ~2h. By default, only a subset of the parameter space is evaluated. Edit `herd_isactive.sh` to run more configurations.

**TODO: how to interpret the results**

### Reproducing Table 2

### Reproducing Figure 5

#### Evaluating HERD
From the gateway, run:
```sh
experiments/kvstore/vanilla_herd.sh
```
Find the generated information under `experiments/kvstore/logs/vanilla_herd/latency_{put,get}/m4/logs/herd-client.txt`.

**TODO: how to interpret the results**

#### Evaluating dynamic HERD 
From the gateway, run:
```sh
experiments/kvstore/dynamic_herd.sh
```
Find the generated information under `experiments/kvstore/logs/dynamic_herd/latency_{put,get}_majority/m4/logs/herd-client.txt`

**TODO: how to interpret the results**

#### Evaluating HERD+Mu
From the gateway, run:
```sh
experiments/kvstore/herd_mu.sh
```
Find the generated information under `experiments/kvstore/logs/herd_mu/latency_{put,get}/m4/logs/herd-client.txt`.
The failover time is gathered in `logs/herd_mu/put_failover.txt`.
> Note: Edit `experiments/kvstore/herd_mu.sh` to increase the number of samples for failover.

**TODO: how to interpret the results**

#### Evaluating uKharon-KV
From the gateway, run:
```sh
experiments/kvstore/herd_ukharon.sh
```
Find the generated information under `experiments/kvstore/logs/herd_ukharon/latency_{get,put}_majority/m4/logs/herd-client.txt`.
The failover time is gathered in `logs/herd_ukharon/ukharonkv_failover_with{,out}_cache.txt`.
> Note: Edit `herd_ukharon.sh` to increase the number of samples for failover.

**TODO: how to interpret the results**

# Detailed instructions

This section will guide you on how to build, configure, and run all experiments **from scratch** to reproduce the results presented in our submission.

Although we provide detailed instructions, building all dependencies and configuring the experimental machines can be tedious. As we do not expect you to have the hardware and permissions required to deploy our artifacts from scrath, we suggest you:
* follow the instructions to build the artifacts (which do not require specific hardware),
* skip hardware configuration steps,
* upload and run the experiments from the gateway provided in [Getting started](#getting-started).

## Cluster prerequisites

If you decide not to use our live environment, running (all) experiments requires:
* a cluster of 8 machines connected via an InfiniBand fabric,
* permissions to install a custom kernel,
* Ubuntu 20.04 (different systems may work, but they have not been tested),
* all machines to have FQDNs (further instructions on this matter will be given when needed),
* all machines having the following ports open: 7000-7100, 11211, 18515.

## Generating the artifacts

The artifcats can either be built on your own deployment machine or directly on the provided cluster. The latter already meets all dependencies and lets you jump to [Building the artifacts](#building-the-artifacts).

### Installing dependencies

#### Apt and PIP dependecies
Install the required dependency on a vanilla Ubuntu 20.04 installation by running:
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

#### Mellanox OFED dependency

Intstall the latest userspace OFED driver by running:

```sh
wget http://www.mellanox.com/downloads/ofed/MLNX_OFED-5.3-1.0.0.1/MLNX_OFED_LINUX-5.3-1.0.0.1-ubuntu20.04-x86_64.tgz
tar xf MLNX_OFED_LINUX-5.3-1.0.0.1-ubuntu20.04-x86_64.tgz
sudo ./mlnxofedinstall --without-fw-update --user-space-only
```

### Building the artifacts

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

# Deploying and running the tests
In order to configure the deployment and run the experiments, follow the instructions under [`experiments`](experiments/).
