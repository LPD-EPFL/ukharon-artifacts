# Impact of uKharon on HERD's throughput

## Payload
Copy the `herd-build/payload.zip` to the present directory.
For example, if you run the experiments from your laptop, you will need to scp the payload from the deployment machine where you built the binaries.

## Original HERD
Simply run
```sh
./herd_stock.sh
```
Find the generated information under `logs/stock_*/m1/logs/workers.txt`.

## uKharon's overhead
Simply run
```sh
./herd_isactive.sh
```
Find the generated information under `logs/stock_*/m4/logs/workers.txt`.
The reduction in throughput is uKharon's overhead.
