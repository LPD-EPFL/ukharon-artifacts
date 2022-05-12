# Coordinated failures

## Payload
Copy the `ukharon-build/payload.zip` to the present directory.
For example, if you run the experiments from your laptop, you will need to scp the payload from the deployment machine where you built the binaries.

## Failure of an Application node
Simply run
```sh
./failover_app.sh
```
The failover time is gathered in `logs/failover_app/latency_*_*.txt`, depending on the use of deadbeat and the existence of a Lease cache.
> Note: Edit `failover_app.sh` to increase the number of samples for failover.

## Coordinated failure of an Application node and the Coordinateor primary
Simply run
```sh
./failover_app_coord.sh
```
The failover time is gathered in `logs/failover_app_coord/latency_*_*.txt`, depending on the use of deadbeat and the existence of a Lease cache.
> Note: Edit `failover_app_coord.sh` to increase the number of samples for failover.

## Coordinated failure of an Application node and a Lease cache
Simply run
```sh
./failover_app_leasecache.sh
```
The failover time is gathered in `logs/failover_app_leasecache/latency_*.txt`, depending on the use of deadbeat.
> Note: Edit `failover_app_leasecache.sh` to increase the number of samples for failover.

## Coordinated failure of an Application node, the Coordinator primary and a Lease cache
Simply run
```sh
./failover_app_leasecache_coord.sh
```
The failover time is gathered in `logs/failover_app_leasecache_coord/latency_*.txt`, depending on the use of deadbeat.
> Note: Edit `failover_app_leasecache_coord.sh` to increase the number of samples for failover.
