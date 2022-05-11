# Impact of uKharon on HERD's throughput

## Payload
Copy the `herd-build/payload.zip` to the present directory.
For example, if you run the experiments from your laptop, you will need to scp the payload from the deployment machine where you built the binaries.

## Original HERD
First, ensure that hugepages are enabled, as the are [required](https://github.com/efficient/rdma_bench#required-settings) by HERD.
In the deployment machines run the following command:
```sh
# `node0` refers to the first NUMA node. Make sure to adapt this to your setup.
# Select the NUMA node closer to the RDMA NIC.
echo 8192 | sudo tee /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
```

Them, simply run
```sh
./herd_stock.sh
```
Find the generated information under `logs/stock_*/m1/logs/workers.txt`.
> Note: Edit `herd_stock.sh` to run various configurations.

## uKharon's overhead
Simply run
```sh
./herd_isactive.sh
```
Find the generated information under `logs/isactive_*/m4/logs/workers.txt`.
The reduction in throughput is uKharon's overhead.
> Note: Edit `herd_isactive.sh` to run various configurations.
