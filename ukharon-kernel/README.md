# uKharon's Custom Kernel

This document describes how to configure, build and install uKharnon's custom kernel for Ubuntu 20.04.
The custom kernel is pacakged in .deb files that can be easily installed on your target system.

## Prerequisites:
By default, the environment to build the kernel utilizes Docker. Alternatively, you can build the kernel in an existing Ubuntu 20.04 system that does not have Docker. 

In the absense of Docker, simply `apt-get install` the dependencies mentioned in the `Dockerfile`, decompress `ukharon_custom_kernel.tar` to `/opt/kernel` and continue with the [Build the custom kernel](#build-the-custom-kernel) section.

## Deploying the Docker container
To setup the build environment, run the following
```sh
./build.sh
./create-volume.sh
./run.sh
````
You are now connected in the Docker container as root. Type `su user` to switch to a normal user.

## Building the custom kernel
Everything necessary to build the custom kernel is stored at `/opt/kernel`.
The build process simply and consist of a few steps:
1. If running from docker, run `cd /app && cp -r /opt/kernel/* .`. Otherwise, go to the artifact directory with `cd /opt/kernel`.
2. Set the number of cores in `scripts/config`. This variable specifies the number of cores that will be used to build the kernel. More cores means faster compilation. Avoid assigning all cores to the compilation process as you will soon run out of memory! Spare a couple of cores. For example, in a system with 8 cores set `CORES=6`.
3. Unpack the kernel and apply Canonical's standard patches with `scripts/unpack.sh`.
4. Apply uKharon's patches with `scripts/prepare.sh`.
5. Configure the kernel with `scripts/configure.sh`. 
A prompt will appear asking questions. Type `N` and hit `Enter` on "Forcing context tracking". For the rest of the questions go with `Y` and in the menuconfig type `Tab` (selects `<Exit>`), hit `Enter`, and then `Enter` again to save the configuration. 
6. Build the kernel with `scripts/build.sh`. Be patient, building takes time!
7. Compress the all the debs:
```sh
tar caf kernel_debs.tar \
linux-headers-5.4.0-74-custom_5.4.0-74.83+rtcore+heartbeat+nohzfull_amd64.deb \
linux-headers-5.4.0-74_5.4.0-74.83+rtcore+heartbeat+nohzfull_all.deb \
linux-image-unsigned-5.4.0-74-custom_5.4.0-74.83+rtcore+heartbeat+nohzfull_amd64.deb \
linux-modules-5.4.0-74-custom_5.4.0-74.83+rtcore+heartbeat+nohzfull_amd64.deb \
linux-modules-extra-5.4.0-74-custom_5.4.0-74.83+rtcore+heartbeat+nohzfull_amd64.deb \
linux-tools-5.4.0-74-custom_5.4.0-74.83+rtcore+heartbeat+nohzfull_amd64.deb
```
8. Exit the docker container by using `exit` twice.
9. Run `./extract.sh` to fetch the `ukharon_kernel_debs.tar`.
10. Finally, run `./destroy.sh` to clean-up the docker image.

## Fetching the .debs
Exit the docker container using `exit` twice.
Then, run `./extract.sh` to store the .debs under the `debs` directory, and distribute them to the desired machines for installation.

## Installing the .debs
On the target machines, upload `ukharon_kernel_debs.tar`.
Install the debs as follows:
```sh
mkdir -p debs && tar xf ukharon_kernel_debs.tar -C debs
sudo dpkg -i debs/*
```

If the installation fails due to missing packages, run
```sh
sudo apt install -y --fix-broken
```

## Booting the custom kernel
To boot the custom kernel, go to `/boot/grub/grub.cfg` and look for the appropriate menuentry.
The menuentry you are looking for is labeled `Ubuntu, with Linux 5.4.0-74-custom`. There are two entries with this label, find the one that is not the recovery mode.
One way to do this quickly is with
```sh
grep "'Ubuntu, with Linux 5.4.0-74-custom'" /boot/grub/grub.cfg
# Example output:
# menuentry 'Ubuntu, with Linux 5.4.0-74-custom' --class ubuntu --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-5.4.0-74-custom-advanced-efaec211-a4ac-4b5a-a1cb-1f8eb3db35f3' {
```
The second part of the fully qualified name of the entry is given at the end of the line. In the above example it's `gnulinux-5.4.0-74-custom-advanced-efaec211-a4ac-4b5a-a1cb-1f8eb3db35f3`.
To determine the first part of the fully qualified name, look for the submenu that encompases this menuentry. Typically, it is the 'Advanced options for Ubuntu' submenu and one ways to quickly find it is with
```sh
grep "'Advanced options for Ubuntu'" /boot/grub/grub.cfg
# Example output:
# submenu 'Advanced options for Ubuntu' $menuentry_id_option 'gnulinux-advanced-efaec211-a4ac-4b5a-a1cb-1f8eb3db35f3' {
```
In the example above, the first part of the fully qualified name is `gnulinux-advanced-efaec211-a4ac-4b5a-a1cb-1f8eb3db35f3`.

The fully qualified name has the form *`first_part`*`>`*`second_part`*. In the above example it's
`gnulinux-advanced-efaec211-a4ac-4b5a-a1cb-1f8eb3db35f3>gnulinux-5.4.0-74-custom-advanced-efaec211-a4ac-4b5a-a1cb-1f8eb3db35f3`

Modify (or introduce it if it does not exist) the `GRUB_DEFAULT` variable in `/etc/default/grub` and set it to fully qualified name. For our example:
```sh
GRUB_DEFAULT='gnulinux-advanced-efaec211-a4ac-4b5a-a1cb-1f8eb3db35f3>gnulinux-5.4.0-74-custom-advanced-efaec211-a4ac-4b5a-a1cb-1f8eb3db35f3'
```
For optimal performance, also extend (or set if it does not exist) the `GRUB_CMDLINE_LINUX_DEFAULT` variable with the kernel parameters
`mce=off intel_pstate=disable poll=idle isolcpus=nohz,domain,8,24,10,26,12,28,14,30 nohz_full=8,24,10,26,12,28,14,30 rcu_nocbs=8,24,10,26,12,28,14,30 rcu_nocb_poll`.
The sequence `8,24,10,26,12,28,14,30` in the above command is given as an example. It specifies the cores that are isolated from the Linux scheduler. Configure it appropriately as explained in the guide on how to build Mu.

Finally, run `sudo update-grub2` to regenerate the grub configuration. Reboot the machine and:
1. Run `uname -a` to check that the custom kernel is booted.
2. Run `cat /proc/cmdline` to check that the kernel parameters for optimal performance are loaded.
