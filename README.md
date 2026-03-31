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

Clone the flake down:

```sh
git clone github:fuguesoft/flake-test
```


We can't just install from this point without tweaking a few things. First,
generate the system and configurations at `/mnt/etc/nixos`:

```sh
nixos-generate-config --root /mnt --flake
```

Then copy the `hardware-configuration.nix` into your flake overwriting the
existing file:

```sh
cp -f /mnt/etc/nixos/hardware-configuration.nix /path/to/flake-test
```

In the `/path/to/flake-test/configuration.nix` make sure to update the user and
hostname fields as desired.

Install NixOS, passing the `--no-root-password` flag to disable the root
account. Include the path to this repository along with the desired
configuration as the `--flake` parameter. Example for configuration `indigo`:

`nixos-install --no-root-password --flake path/to/fuguesoft/flake-test#indigo`

**Before reboot**, make a password for your user. For the user `fugue`:

```sh
nixos-enter --root /mnt -c 'passwd fugue'
# enter and confirm password
reboot
```

#### Troubleshooting

It may be that the `/` and `/home` uuids are not found after a reboot. If that
is the case, you'll need to reapat some of the process again:

1. Boot into the recovery ISO remount the disks.
2. Generate the configs once more
3. Edit the `hardware-configuration.nix` and replace the
   `fileSystems."{device-name}".device` with `fileSystem."{device-name}".label`

Example:

```nix
{ config, lib, pkgs, modulesPath, ... }:

{
  # ...
  fileSystems."/" =
    { 
      # device = "/dev/disk/by-uuid/c5a651f2-60a0-417b-a03b-2219843481a8";
      label = "nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { 
      # device = "/dev/disk/by-uuid/E7C2-0E41";
      label = "boot";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/home" =
    { 
      # device = "/dev/disk/by-uuid/cdabbcd5-761d-4472-bc25-195c5a771a19";
      label = "home";
      fsType = "ext4";
    };

  swapDevices = [ { device = "foobar" } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

Then copy the file over again, run the install and set the password

### Linux (Non-nix)

### macOS

### Windows
