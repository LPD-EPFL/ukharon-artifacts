# uKharon-KV Latency and Failover

## Payload
Copy the `ukharon-build/payload.zip` to the present directory.
For example, if you run the experiments from your laptop, you will need to scp the payload from the deployment machine where you built the binaries.

## HERD
Simply run
```sh
./vanilla_herd.sh
```
Find the generated information under `logs/vanilla_herd/latency_{put,get}/m4/logs/herd-client.txt`.

## Dynamic HERD 
Simply run
```sh
./dynamic_herd.sh
```
Find the generated information under `logs/dynamic_herd/latency_{put,get}_majority/m4/logs/herd-client.txt`

## HERD+Mu
Simply run
```sh
./herd_mu.sh
```
Find the generated information under `logs/herd_mu/latency_{put,get}/m4/logs/herd-client.txt`.
The failover time is gathered in `logs/herd_mu/put_failover.txt`.

## uKharon-KV
Simply run
```sh
./herd_ukharon.sh
```
Find the generated information under `logs/herd_ukharon/latency_{get,put}_majority/m4/logs/herd-client.txt`.
The failover time is gathered in `logs/herd_ukharon/ukharonkv_failover_with{,out}_cache.txt`.
