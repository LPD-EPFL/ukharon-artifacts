# Overview
uKharon is a membership service for microsecond applications.

This repository contains the artifacts and instructions needed to reproduce the experiments in our [ATC paper](https://www.usenix.org/conference/atc22/presentation/guerraoui).
More precisely, it contains:
* Instructions on how to build and install the custom Linux kernel as well as the failure detection module.
* Instructions on how to build the payloads for the different experiments.
* Instructions on how to launch the experiments and obtain the results.

By running the experiments, you should be able to reproduce the numbers shown in:
* **Figure 3**: Percentage of timely lease renewal depending on the lease duration, network load and memory load
* **Figure 4**: Impact of uKharon on HERD's throughput
* **Table 2**: Failover time upon various failures
* **Figure 5**: Latency comparison of vanilla HERD, HERD+Mu and uKharon-KV

# Detailed instructions

This section will guide you on how to build, configure, and run all experiments, **from scratch**, to reproduce the results presented in our paper.

## Cluster prerequisites

Running all experiments requires:
* a cluster of 8 machines connected via an InfiniBand fabric,
* permissions to install a custom kernel,
* Ubuntu 20.04 (different systems may work, but they have not been tested),
* all machines to have FQDNs (further instructions on this matter will be given when needed),
* all machines having the following ports open: 7000-7100, 11211, 18515.

### Dependencies

Prepare the machines on your cluster by installing the following dependencies:
```sh
apt install -y sudo coreutils util-linux gawk python3 zip tmux gcc numactl stress-ng memcached
apt install -y perftest # only if Mellanox OFED is not installed (see below).
```

## Generating the artifacts

### Installing dependencies

#### Apt and PIP dependecies
Install the required dependency on a vanilla Ubuntu 20.04 installation by running:
```sh
sudo apt-get -y install \
    python3 python3-pip \
    gawk build-essential cmake ninja-build \
    libmemcached-dev \
    libibverbs-dev # only if Mellanox OFED is not installed (see below).

sudo apt-get -y install libnuma-dev # only required to build HERD

pip3 install --upgrade "conan>=1.47.0"
```

#### Mellanox OFED dependency

Install the appropriate OFED driver by running:

```sh
wget http://www.mellanox.com/downloads/ofed/MLNX_OFED-5.3-1.0.0.1/MLNX_OFED_LINUX-5.3-1.0.0.1-ubuntu20.04-x86_64.tgz
tar xf MLNX_OFED_LINUX-5.3-1.0.0.1-ubuntu20.04-x86_64.tgz
sudo ./mlnxofedinstall
```

### Building the artifacts

Assuming all the machines in your cluster have the same configuration, you need to:
* build all the necessary binaries in one deployment machine,
* package them and deploy them in all 8 machines.

The building process is long and complex. Follow the instructions in each one of the following sub-directories:
* Compile and boot uKharon's kernel, as explained in [`ukharon-kernel`](ukharon-kernel/).
* Install the failure detection kernel modules (on the deployment machines), as explained in [`ukharon-kernel-modules`](ukharon-kernel-modules/).
* Build Mu (on a deployment machine), as explained in [`mu-build`](mu-build/).
* Build uKharon (on a deployment machine), as explained in [`ukharon-build`](ukharon-build/).
* Build HERD (on a deployment machine), as explained in [`herd-build`](herd-build/).

Once you have finished with the above steps, the binaries will be packaged in `payload.zip` files.

# Deploying and running the tests
In order to configure the deployment and run the experiments, follow the instructions under [`experiments`](experiments/).

__Note:__ For brevity, the parameter space explored by the scripts has been reduced drastically so that each experiment runs in a few minutes. Feel free to edit the scripts to explore more and reproduce all the results. We do not provide the scripts that generate the figures themselves.

__Gateway:__ To run the experiments we assume the existence of gateway machine that has access to all 8 machines. This machine may be one of the deployment machines or e.g., your laptop. The gateway orchestrates the execution and gathers the experimental results.

### Reproducing Figure 3

From the gateway, run:
```sh
ukharon-artifacts/experiments/stress/stress.sh
```

> Note: Edit stress.sh to run more/different configurations.

Find the generated data under `ukharon-artifacts/experiments/stress/logs/inactivity_maj${LEASE_DURATION}_net${NETWORK_LOAD}_mem${MEMRATE}/m4/logs/active-renewer.txt`.

For each (`LEASE_DURATION`, `NETWORK_LOAD`, `MEMRATE`), the inactivity rate is computed with the following formula: `inactivity_rate = (inactive_samples - first_active_sample + 1)/(number_of_samples - first_active_sample + 1)`.

The `MEMRATE` can be translated to a memory load according to the following table:

| Memrate | Memory Load |
|---------|-------------|
| 3       | ~50%        |
| 4       | ~65%        |
| 5       | ~85%        |
| 6       | ~100%       |

> Note: We estimated the memory load by running multiple `stress-ng` commands and crosscheckking the numbers with the [zsmith](https://zsmith.co/bandwidth.php) memory-bandwidth tool.

### Reproducing Figure 4

#### Evaluating stock Herd
From the gateway, run:
```sh
ukharon-artifacts/experiments/herd/herd_stock.sh
```
> Note: Running the full experiments takes ~2h. By default, only a subset of the parameter space is evaluated. Edit `herd_stock.sh` to run more configurations.

Find the generated data under `ukharon-artifacts/experiments/herd/logs/stock_w${WORKERS}_p${BATCH_SIZE}/m1/logs/workers.txt`.

Each worker reports its average throughput. Each bar in the figure is the average of the throughput accross workers.

#### Evaluating uKharon's overhead
From the gateway, run:
```sh
ukharon-artifacts/experiments/herd/herd_isactive.sh
```
> Note: Running the full experiments takes ~2h. By default, only a subset of the parameter space is evaluated. Edit `herd_isactive.sh` to run more configurations.

Find the generated data under `ukharon-artifacts/experiments/herd/logs/isactive_w${WORKERS}_p${BATCH_SIZE}/m4/logs/workers.txt`.

Each worker reports its average throughput. Each bar in the figure is the average of the throuhgput accross workers.

### Reproducing Table 2

The live environment we provide is slightly different from the one we used to run the evaluation in our paper.
Notably, the cluster we provide is not perfectly symmetrical (i.e., only half of the machines are booted with the custom kernel), resulting in increased variance in failover evaluation.
You should thus expect slightly degraded results (i.e., higher failover times).

> Note: For brevity, the scripts run only 1 iteration. Edit them for better results.

#### First column

From the gateway, run:
```sh
ukharon-artifacts/experiments/failover/failover_app.sh
```

Find the generated data under `ukharon-artifacts/experiments/failover/logs/failover_app/latency_{maj,cache}_{no,}deadbeat.txt`.
The number you are interested in is `s->a`, which measures the time difference between when the *kill **S**ignal* is sent over the network and the new membership becomes **A**ctive.

#### Second column

From the gateway, run:
```sh
ukharon-artifacts/experiments/failover/failover_app_coord.sh
```

Find the generated data under `ukharon-artifacts/experiments/failover/logs/failover_app_coord/latency_{maj,cache}_{no,}deadbeat.txt`.

#### Third column

From the gateway, run:
```sh
ukharon-artifacts/experiments/failover/failover_app_leasecache.sh
```

Find the generated data under `ukharon-artifacts/experiments/failover/logs/failover_app_leasecache/latency_{no,}deadbeat.txt`.

#### Fourth column

From the gateway, run:
```sh
ukharon-artifacts/experiments/failover/failover_app_leasecache_coord.sh
```

Find the generated data under `ukharon-artifacts/experiments/failover/logs/failover_app_leasecache_coord/latency_{no,}deadbeat.txt`.

### Reproducing Figure 5

#### Evaluating HERD
From the gateway, run:
```sh
ukharon-artifacts/experiments/kvstore/vanilla_herd.sh
```
Find the generated data under `ukharon-artifacts/experiments/kvstore/logs/vanilla_herd/latency_{put,get}/m4/logs/herd-client.txt`.

#### Evaluating dynamic HERD 
From the gateway, run:
```sh
ukharon-artifacts/experiments/kvstore/dynamic_herd.sh
```
Find the generated data under `ukharon-artifacts/experiments/kvstore/logs/dynamic_herd/latency_{put,get}_majority/m4/logs/herd-client.txt`.

#### Evaluating HERD+Mu
From the gateway, run:
```sh
ukharon-artifacts/experiments/kvstore/herd_mu.sh
```
Find the generated information under `ukharon-artifacts/experiments/kvstore/logs/herd_mu/latency_{put,get}/m4/logs/herd-client.txt`.
The failover time is gathered in `ukharon-artifacts/experiments/kvstore/logs/herd_mu/put_failover.txt`.
> Note: Edit `herd_mu.sh` to increase the number of samples for failover.

> Note: In order to be as fair as possible with Mu, we aggressively lowered its failure detection threshold. This may cause oscillations/failures and you may have to re-run the test.

#### Evaluating uKharon-KV
From the gateway, run:
```sh
ukharon-artifacts/experiments/kvstore/herd_ukharon.sh
```
Find the generated information under `ukharon-artifacts/experiments/kvstore/logs/herd_ukharon/latency_{get,put}_majority/m4/logs/herd-client.txt`.
The failover time is gathered in `ukharon-artifacts/experiments/kvstore/logs/herd_ukharon/ukharonkv_failover_with{,out}_cache.txt`.
> Note: Edit `herd_ukharon.sh` to increase the number of samples for failover.
