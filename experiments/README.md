# uKharon's experiments
This directory explains how to automatically run uKharon's experiments

## Configuring the scripts
The file `base-scripts/config.sh` needs to be configured before running the experiments. Several variables need to be set as explained below:
Note that the deployment scripts need not run from a deployment machine. You can instead run them e.g., from your laptop.

---

```sh
ROOT_DIR
```
It defines the root directory where the scripts deploy the precompiled binaries in the deployment machines.
The default value is the home directory of the user used to access the deployment machines.

---

```sh
machine1
machine2
machine3
machine4
machine5
machine6
machine7
machine8
```
These variables define the symbolic names to access the deployment machines over ssh. To setup these symbolic names you need to edit `~/.ssh/config` in the machine you run the deployment scripts from (e.g., your laptop). You can learn how to do this [here](https://linuxize.com/post/using-the-ssh-config-file/).

It is important to be able to access the deployment machines without password. Thus, you need to install ssh keys. You can learn how to do this [here](https://www.cyberciti.biz/faq/ubuntu-18-04-setup-ssh-public-key-authentication/).
If your key contains a passphrase, you can rely on `ssh-agent`, also explained in the above previous link.

For example, the following entry in `~/.ssh/config`
```
Host delta1
  HostName lpdquatro1.epfl.ch
  User user
  Port 22
  IdentityFile ~/.ssh/id_rsa
  ServerAliveInterval 120
```
Allows you to access the machine by merely typing `ssh delta1`. 

---

```sh
machine1hostname
machine2hostname
machine3hostname
machine4hostname
machine5hostname
machine6hostname
machine7hostname
machine8hostname
```
These variables define the Fully Qualified Domain Names (FQDN) of these machines. Every machine should be able to access every other machine using the corresponding FQDN.
You can learn how to setup the FQDNs [here](https://linuxconfig.org/how-to-change-fqdn-domain-name-on-ubuntu-20-04-focal-fossa-linux).

---

```sh
REGISTRY_MACHINE
```
It defines which machine is going to run the memcached server needed to exchange QP information when setting up RDMA connections.
Make sure that `memcached` is installed in the declared machine and that its port 11211 is open.

---

```sh
UKHARON_MCGROUP
UKHARON_KERNELMCGROUP
```
Set these variables with the information retrieved when building `ukharon-build`.

---

```sh
UKHARON_SYNCKILLERMCGROUP
```
Set this variable to another InfiniBand multicast group.
It is used by the `sync_killer` to trigger `SIGKILL`s remotely and thus simulate coordinated failures.

---

```sh
UKHARON_HAVE_SUDO_ACCESS
UKHARON_SUDO_ASKS_PASS
UKHARON_SUDO_PASS
```
Sudo access is necessary to achieve optimal performance. These variables refer to the deployment machines.
If you have sudo access in the deployement machines, set the first variable to `true`. 
If when issuing a command with sudo you need to type your password, set the second variable to `true` and put the password in the third variable.

---

```sh
UKHARON_CPUNODEBIND
UKHARON_CPUMEMBIND
```
Set the variables, which refer to the deployment machines, to achieve optimal performance. 
In a multi-socket machine, set `UKHARON_CPUNODEBIND` to the socket that is closer to the RDMA NIC and `UKHARON_CPUMEMBIND` to the memory that is closer to this socket.
The instructions in `mu-build` explain how to retrieve this information.

---

```sh
UKHARON_MEMSTRESS_CORES
```
These are the cores (in the deployment machines) that are used by `stress-ng` for memory stressing. These cores must not interfer with the cores selected in `ukharon-build`.

## Running the experiments
* To run the experiment of figure 3, go to the `stress` directory
* To run the experiment of figure 4, go to the `herd` directory
* To run the experiment of figure 5, go to the `kvstore` directory

