# Building uKharon

uKharon requires setting its configuration file appropriately before building.
The instructions below provide all necessary steps to build uKharon.

## Preparation
First, download uKharon from its repository and copy into it Mu's library.
Use the credentials provided in HotCRP to fetch the repository.
```sh
scripts/prepare.sh
```

## Configuration
Configuring uKharon entails:
* Setting the appropriate core pinning.
* Setting the multicast groups.

### Core pinning
uKharon uses the cores defined at the bottom of `ukharon/membership/src/default-config.hpp`. Follow the same guidelines as described in Mu. Since Mu and uKharon never co-exist, you can pin uKharon to the same cores as Mu.

For example, in our setup we use:
```
static constexpr int LeaseCheckingCore = 10;
static constexpr int FdCore = 8;
static constexpr int MembershipManagerCore = 14;
```

You also have to edit `ukharon/demo/src/herd/mu/config.hpp` to set the pinning for the HERD+Mu experiment. Again, follow the same guidelines.

Continuing the example above, we set `HerdClientCore` to the `LeaseCheckingCore` and `HerdServerCore` to a core that is **not** used by Mu.

### Setting the Multicast groups
uKharon relies on RDMA Multicast. It uses two multicast groups, one for broadcasting new views and one for emitting failure notification from the kernel.

To use this feature, you need to determine the multicast groups in your setup as follows:

First determine the `lid` of the switch.
```sh
ibswitches
> Returns:
> Switch	: 0x248a070300f88040 ports 36 "MF0;lpdswitch1:MSB7700/U1" enhanced port 0 lid 1 lmc 0
```
In the example above `lid` is 1.

Then, using this `lid`, dump the Multicast groups:
```sh
ibroute -M 1
> Returns:
> Multicast mlids [0xc000-0xc01f] of switch Lid 1 guid 0x248a070300f88040 (MF0;lpdswitch1:MSB7700/U1):
>             0                   1                   2                   3             
>      Ports: 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 
>  MLid
> 0xc000      x     x     x x x         x   x                                   x x     
> 0xc004      x     x     x x x         x   x                                   x x     
> 0xc005      x     x     x x x         x   x                                   x x     
> 0xc00b                                x   x                                   x x     
> 4 valid mlids dumped 
```

In the example above, MLid `0xc004` applies to all machines (there are 8 horizontal "x" letters), thus it's suitable.

Then, find the MGID of two multicast groups:
```sh
saquery -g
> Returns:
MCMemberRecord group dump:
		MGID....................ff12:401b:ffff::1
		Mlid....................0xC004
		Mtu.....................0x84
		pkey....................0xFFFF
		Rate....................0x83
		SL......................0x0
...
MCMemberRecord group dump:
		MGID....................ff12:601b:ffff::1:ff28:cf2a
		Mlid....................0xC006
		Mtu.....................0x84
		pkey....................0xFFFF
		Rate....................0x83
		SL......................0x0
...
```

Then combine the Mlid with each of the MGID in the format `<MGID>/<MLid>`. Thus, the two multicast groups in the example are:
```sh
ff12:601b:ffff::1:ff28:cf2a/0xc004 # Used to broadcast new memberships
ff12:401b:ffff::1/0xc004 # Used by the kernel (deadbeat)
```

Finally, `ukharon/membership/libgen/src/config.hpp` and set the above groups.

### Compiling
Now that everything is configured, simply run:
```sh
scripts/compile.sh
```
A prompt asks you whether you the appropriate configuration is set. Type `y` and hit `Enter` to continue. Compilation may take a few minutes to complete.

### Packaging
All the necessary binaries are generated. Package them by running:
```sh
scripts/payload.sh
```
A `payload.zip` is created that contains all the necessary code that needs to be executed for the experiment.

