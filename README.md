# multipass-config

Edgebox Unattended Install Process for Canonical Multipass.

## Overview

This repository contains a set of scripts and configuration files to automate the installation of Edgebox on a Multipass VM. The scripts are designed to be run on a Linux host, and will create a Multipass VM, install Edgebox, and configure it to run on boot.

## Prerequisites

* A Linux or MacOS host with Multipass installed (see [Multipass](https://multipass.run/))

_Note: Since Multipass is also multi-platform, it should also run in Windows, albeit you will need to manually run the commands in the `Makefile`._

## Installation

1. Clone this repository to your Linux host.
2. Run `make install`
3. Access `http://edgebox.local` in your browser.

## Configuration

The `make install` command accepts the following arguments:

* `hostname` - The name of the Multipass VM to create. Defaults to `edgebox`.
* `cpus` - The number of CPUs to allocate to the VM. Defaults to `2`.
* `memory` - The amount of memory to allocate to the VM. Defaults to `4G`.
* `disk` - The size of the disk to allocate to the VM. Defaults to `50G`.
* `log` - The log verbosity to use. Defaults to `v`. Valid values are `v`, `vv`, `vvv`, `vvvv`, and `vvvvv`.
* `system-pw` - The password to use for the `system` user. Defaults to `pw`.

## Example

The following command will create a Multipass VM named `edgebox` with 4 CPUs, 8GB of memory, and 100GB of disk space. It will also set the `system` user password to `password` and configure the necessary components to run the Edgebox system:

```bash
make install hostname=edgebox cpus=4 memory=8G disk=100G system-pw=password
```

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
