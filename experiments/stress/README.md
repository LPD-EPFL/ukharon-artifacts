# Effect of lease duration, network and memory load on timely lease renewal

## Payload
Copy the `ukharon-build/payload.zip` to the present directory.
For example, if you run the experiments from your laptop, you will need to scp the payload from the deployment machine where you built the binaries.

## Periods of inactivity
Simply run
```sh
./stress.sh
```
Find the generated information under `logs/inactivity_maj*_net*_mem*/m4/logs/active-renewer.txt`.
> Note: Edit `stress.sh` to run various configurations.
