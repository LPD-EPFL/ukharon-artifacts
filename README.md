# uKharon
uKharon is a membership service for microsecond applications.
This repository contains all the artifacts needed to run the experiments in the paper.

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
* Compile and boot uKharon's kernel, as explained in `ukharon-kernel`.
* Install the Mellanox's OFED driver (in the deployment machines), as explained in `ukharon-kernel-modules`.
* Build Mu (in a deployment machine), as explained in `mu-build`.
* Build uKharon (in a deployment machine), as explained in `ukharon-build`.
* Build HERD (in a deployment machine), as explained in `herd-build`.

Once you have finished with the above steps, the binaries will be packaged in `payload.zip` files.

# How to deploy
To deploy the various experiments, follow the instructions under `experiments`.
