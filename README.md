# multipass-config

Edgebox Unattended Install Process for Canonical Multipass.

## Overview

This repository contains a set of scripts and configuration files to automate the installation of Edgebox on a Multipass VM. The scripts are designed to be run on a host that supports Makefiles and bash scripts, and will create a Multipass VM, install the Edgebox inside it, and configure it to run on boot.

## Prerequisites

### Make

* Linux and MacOS have it pre-installed.
* Windows: run as Administrator `choco install make`

### Multipass

* MacOS: run `brew install multipass`
* Linux: run as `snap install multipass` as root/sudo
* Windows: run `choco install multipass` as Administrator

Fore more information on multipass, check [the official website](https://multipass.run/).

### Multicast DNS

* MacOS supports mDNS out of the box
* Most linux distributions support it out of the box. If not, you can install the `avahi-daemon` [package](https://avahi.org/).
* Windows: run `choco install bonjour`

For more information about mDNS, check this [Wikipedia entry](https://en.wikipedia.org/wiki/Multicast_DNS).

### (Windows Only) Virtualbox

* Download the `.exe` via the [official page](https://www.virtualbox.org/wiki/Downloads) and run the installer as Administrator.
* Set Multipass to use Virtualbox as a provider by running `multipass set local.driver=virtualbox` also as Administrator.

## Installation

1. Clone this repository to your machine.
2. Run `make install` in the repository folder.

### Install Options

The `make install` command accepts the following arguments:

* `hostname` - The name of the Multipass VM to create. Defaults to `edgebox`.
* `cpus` - The number of CPUs to allocate to the VM. Defaults to `2`.
* `memory` - The amount of memory to allocate to the VM. Defaults to `4G`.
* `disk` - The size of the disk to allocate to the VM. Defaults to `50G`.
* `log` - The log verbosity to use. Defaults to `v`. Valid values are `v`, `vv`, `vvv`, `vvvv`, and `vvvvv`.
* `system-pw` - The password to use for the `system` user. Defaults to `pw`.

#### Example

The following command will create a Multipass VM named `edgebox` with 4 CPUs, 8GB of memory, and 100GB of disk space. It will also set the `system` user password to `password` and configure the necessary components to run the Edgebox system:

```bash
make install hostname=edgebox cpus=4 memory=8G disk=100G system-pw=password
```

## Access

Once the installation completes, you can access `http://edgebox.local` in your browser or ssh into the system by running `make shell`.

### (Windows Only) Configuring Networking

Under windows, when using Virtualbox as Multipass provider, it is necessary to change the networking mode of the VM so it uses bridge mode instead of NAT. This is necessary so your machine can detect the .local domain names Edgebox issues in the network. This can be done by following a couple of steps.

Multipass runs as the System account, so to see the instances in VirtualBox, or through the VBoxManage command, you have to run those as that user via PsExec -s. 

* Download and unpack [PSTools.zip](https://download.sysinternals.com/files/PSTools.zip) in your Downloads folder, and in an administrative PowerShell, run:

```bash
& $env:USERPROFILE\Downloads\PSTools\PsExec.exe -s -i 'C:\Program Files\Oracle\VirtualBox\VirtualBox.exe
```

This will open the VirtualBox interface and list all Multipass instances running

![Virtualbox running under Windows](https://ubuntucommunity.s3.dualstack.us-east-2.amazonaws.com/optimized/2X/e/edce2443fef2f4b99784d6a87273f26a885d32a3_2_690x445.png)

* Select the machine corresponding to the chosen hostname during installation, and click the "Settings" icon.
* On the left-hand side, click "Network"
* Change the "Adapter 1" to be attached to "Bridged Adapter"
* In the "Name" dropdown, select your active network interface (Wifi card of Ethernet adapter). Click "OK" to save the settings.
* Restart Edgebox by running `make restart`

_Note: Once the machine uses the new network mode, `make start` and `make restart` will issue a timeout error, but the machine will start and restart properly. Aditionally, the native multipass command `multipass shell <hostname>` won't work. This is because multipass cannot properly detect the machine IP when using bridged adapter mode. When using bridged adapter, you can run `ping edgebox.local` to know if the machine is ready to be accessed, and `make shell` also works as expected._

## Uninstall

To uninstall Edgebox, run the following command:

```bash
make uninstall
```

## Starting / Stopping

To start the system, run the following command:

```bash
make start
```

To stop the system, run the following command:

```bash
make stop
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
