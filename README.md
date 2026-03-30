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

#### Connect to the internet

```sh
nmcli --ask device wifi connect <SSID>
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

`/boot`
```sh
mount -o umask=077 --mkdir /dev/<diskID><partition-number> /mnt/boot
```

`/swap`
```sh
swapon /dev/<diskID><diskID><partition-number>
```

`/`
```sh
mount /dev/<diskID><partition-number> /mnt
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

#### Edit /etc/configuration.nix
After all that, run the following command to generate the system and hardware
configs at `/mnt/etc/nixos`:

```sh
nixos-generate-config --root /mnt
```

Edit the generated `configuration.nix`

```sh
vim /mnt/etc/nixos/configuration.nix
```

Add the following to enable flakes:

```nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
```

Make your other desired changes to the generated `configuration.nix` file like
adding a new user, changing the hostname, setting the timezone, etc:

```nix
  # Install some system level utils
  environment.systemPackages = with pkgs; [
    btop
    fd
    git
    home-manager
    nvim
    ripgrep
    tmux
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vampire-steve = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.

    # Install some packages at the user level
    packages = with pkgs; [
      foot
      keyd
      librewolf
      tree
    ];
  };
```

Install NixOS, passing the `--no-root-password` to disable the root account:

`nixos-install --no-root-password `

**Before reboot**, make a password for your user:

```sh
nixos-enter --root /mnt -c 'passwd vampire-steve'
# enter and confirm password
reboot
```

Lastly, run the flake to try it out.

```sh
nix run git@github.com:fuguesoft/flake-test
```

### Linux (Non-nix)

### macOS

### Windows
