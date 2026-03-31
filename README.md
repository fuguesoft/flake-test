# Test Flake (WIP)

This is a test flake for rebuilding my NixOS configuration on a new machine. The
aim is to familiarize myself with the building process so I am comfortable
switching to Nix fulltime.

This readme will be updated with basic installation and/or run instructions for
a variety of systems as I learn how they work.

## Installation

### Linux (Nix)
Mostly taken from:

- The [official guide](https://nixos.org/manual/nixos/stable/#sec-installation-manual)
- Tony Banters [Guide](https://www.tonybtw.com/tutorial/nixos-from-scratch/)

Download the most recent [NixOS ISO](https://nixos.org/download)

Burn the ISO to a drive and boot from it:

```sh
dd if=/path/to/NixOS-iso of=/dev/device-label bs=4M status=progress
```

This guide assumes the minimal installer.

#### Environment

Connect to the internet
```sh
nmcli --ask device wifi connect <SSID>
```

Install some useful tools
```sh
nix-shell -p asciinema tmux
tmux
```

#### Set up partitions and filesystems
Find the diskID with `lsblk -f`.

Partition the drives:

```sh
cfdisk /dev/<diskID>
```

Write the following partitions with the following sizes:
1. EFI System - 1G
2. Linux swap - 4G
3. Linux filesystem - Some number (root)
4. Linux filesystem - The rest (home)

Write the changes and Quit. Confirm your work with `lsblk -f`

After writing those partitions, mount them and prepare for the install:

`/boot`
```sh
mkfs.fat -F 32 -n boot /dev/<diskID><partition-number>
```

`/swap`
```sh
mkswap -L swap /dev/<diskID><partition-number>
```

`/`
```sh
mkfs.ext4 -L nixos /dev/<diskID><partition-number>
```

`/home`
```sh
mkfs.ext4 -L home /dev/<diskID><partition-number>
```

#### Set up mounting
After labeling the drives mount them to their proper mount points.

`/`
```sh
mount /dev/<diskID><partition-number> /mnt
```

`/boot`
```sh
mount -o umask=077 --mkdir /dev/<diskID><partition-number> /mnt/boot
```

`/swap`
```sh
swapon /dev/<diskID><diskID><partition-number>
```

`/home`
```sh
mount --mkdir /dev/<diskID><partition-number> /mnt/home
```

Mount the `efivars`:

```sh
mount -t efivarfs efivarfs /sys/firmware/efi/efivars/
```

Check the partitions with `lsblk -f`

#### Generate Configs
After all that, run the following command to generate the system and hardware
configs at `/mnt/etc/nixos`:

```sh
nixos-generate-config --root /mnt --flake
```

Install NixOS, passing the `--no-root-password` flag to disable the root account. Include the path to this repository along with the desired configuration as the `--flake` parameter:

`nixos-install --no-root-password --flake github:fuguesoft/flake-test#indigo`

**Before reboot**, make a password for your user:

```sh
nixos-enter --root /mnt -c 'passwd fugue'
# enter and confirm password
reboot
```

Become perplexed when the bootloader can't find the devices you set up.

### Linux (Non-nix)

### macOS

### Windows
