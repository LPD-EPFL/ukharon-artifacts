# Building HERD
Before building HERD, make sure you have built uKharon.

## Preparation
First, download HERD from its repository and apply a few minor fixes:
```sh
scripts/prepare.sh
```

## Compilation
Then, build HERD in multiple configurations
```sh
scripts/compile.sh
```

## Packaging
Finally, package all the binaries into a `payload.zip`:
```sh
scripts/payload.sh
```
