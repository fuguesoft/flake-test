{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps= 1
  '';

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  networking.hostName = "indigo"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "es_ES.UTF-8";
  console.keyMap = "es";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "es";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fugue = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      keyd
      librewolf
    ];
  };

  programs.fish.enable = true;
  services.flatpak.enable = true;
  programs.foot.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  programs.niri = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    # localNetworkgameTransfers.openFirewall = true;
  };

  programs.wshowkeys.enable = true;
  programs.ydotool.enable = true;

  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      bigclock = "en";
      # bigclock_seconds = true;
      blank_box = true;
      lang = "es";
      vi_mode = true;
    };
  };

  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
  };

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
          };
        };
      };
    };
  };

  services.passSecretService.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # services.uxplay.enable = true;

  security.pam.services.fugue.gnupg = {
    enable = true;
  };

  security.polkit.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    # alacritty
    btop
    chafa
    elinks
    fd
    foot
    git
    gnumake
    greetd
    home-manager
    inxi
    pciutils
    lukesmithxyz-bible-kjv
    lynx
    man-pages
    man-pages-posix
    mangowc
    ncdu
    neovim
    nil
    niri
    # nixd
    nudoku
    # install pass w/ pass-otp
    (pass.withExtensions (e: [
      e.pass-otp
    ]))
    pinentry-curses
    podman
    quickshell
    ripgrep
    socat
    timg
    tmux
    tuigreet
    unzip
    unrar-free
    uxplay
    vifm
    vim
    w3m
    wayland
    wayland-protocols
    wev
    wget
    # wikiman -- external sources broken
    wl-clipboard
    xwayland-satellite
  ];

  documentation.dev.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.victor-mono
    nerd-fonts.symbols-only
    mplus-outline-fonts.githubRelease
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "aseprite"
      "bitwig-studio-unwrapped"
      "lutris"
      "pureref"
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
      "steamcmd"
      "steam-tui"
    ];

  nix.settings = {
    substituters = [ "https://graphite.cachix.org" ];
    trusted-public-keys = [ "graphite.cachix.org-1:B7Il1yMpkquN/dXM+5GRmz+4Xmu2aaCS1GcWNfFhsOo=" ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    allowed-users = [
      "@wheel"
      "fugue"
    ];
  };

  # FLAKE USAGE for ???
  # nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  # add `inputs` to attrset args at top of file

  # List services that you want to enable:

  system.stateVersion = "25.11"; # Did you read the comment?

}
