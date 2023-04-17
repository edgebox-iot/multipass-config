# multipass-config

Edgebox Unattended Install Process for Canonical Multipass.

## Overview

This repository contains a set of scripts and configuration files to automate the installation of Edgebox on a Multipass VM. The scripts are designed to be run on a Linux host, and will create a Multipass VM, install Edgebox, and configure it to run on boot.

## Prerequisites

* A Linux host with Multipass installed (see [Multipass](https://multipass.run/))

## Installation

1. Clone this repository to your Linux host.
2. Run `make install`

## Configuration

The `make install` command accepts the following arguments:

* `hostname` - The name of the Multipass VM to create. Defaults to `edgebox`.
* `cpus` - The number of CPUs to allocate to the VM. Defaults to `2`.
* `memory` - The amount of memory to allocate to the VM. Defaults to `4G`.
* `disk` - The size of the disk to allocate to the VM. Defaults to `50G`.
* `log` - The log verbosity to use. Defaults to `v`. Valid values are `v`, `vv`, `vvv`, `vvvv`, and `vvvvv`.
* `system-pw` - The password to use for the `system` user. Defaults to `pw`.
