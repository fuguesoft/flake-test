{
  config,
  pkgs,
  lib,
  ...
}:

let
  HOME = config.home.homeDirectory;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "fugue";
  home.homeDirectory = "/home/fugue";

  home.stateVersion = "25.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    asciinema
    # aseprite
    bat
    # bitwig-studio
    bottles
    btop
    tealdeer
    # blender
    bibletime
    # package to watch/package?
    # https://codeberg.org/janantos/brow6el
    # cinny # broken on 25.11
    cmatrix
    codeberg-cli
    cpufetch
    dia
    ddgr
    dialog
    discordo
    dmenu-wayland
    dunst
    espanso
    f3
    fastfetch
    # ffmpeg
    # fluffychat
    # freecad
    gh
    godot
    # goldendict-ng
    # graphite
    groff
    help2man
    heroic
    hyfetch
    # iamb
    # inkscape
    isort
    lilypond
    # lilgptracker
    localsend
    # lutris - requires steam (unfree)
    man
    man-pages
    mandown
    manga-cli
    manga-tui
    manix
    # milkytracker
    mpv
    neomutt
    nethack
    nudoku
    obs-cli
    # openscad
    # pixieditor
    # pureref
    # qrencode
    # reaper
    ripgrep
    # schismtracker
    sioyek
    # solvespace
    # soundtracker
    # sox
    # streamlink
    # streamlink-twitch-gui-bin
    # sway
    # swaybg
    # stremio # outdated qt-engine dependency
    tagainijisho
    teensy-loader-cli
    # tic-80 - requires insecure
    tig
    # whole buncha tmux plugins
    toilet
    tor
    trash-cli
    # verse # gonna package this
    vesktop
    vimiv-qt
    warpd
    waybar
    weechat
    wf-recorder
    # wikiman
    # winboat
    wine-wayland
    winetricks
    wiremix
    xdg-ninja
    xdg-user-dirs
    yewtube
    ytfzf
    yt-dlp
    ytdl-sub
  ];

  # This is for wrapping to avoid using lazy. We'll figure it out on the daily
  # driver.

  # programs.mnw = {
  #   enable = true;
  #   initLua = ''
  #     require{"myconfig"}
  #   '';
  #   plugins = {
  #     start = [
  #       pkgs.vimPlugins.oil-nvim
  #     ];
  #     dev.myconfig = {
  #       pure = ./nvim;
  #     };
  #   };
  # };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "bitwig-studio-unwrapped"
      "aseprite"
      "graphite"
      "lutris"
      "pureref"
      "reaper"
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
      "steamcmd"
      "steam-tui"
      "stremio-shell"
    ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.fish.enable = true;
  programs.lutris.enable = true;

  programs.git = {
    enable = true;
    settings = {
      core.editor = "nvim";
      user = {
        name = "fuguesoft";
        email = "31870368+fuguesoft@users.noreply.github.com";
      };
      init.defaultbranch = "main";
    };
  };

  programs.gh = {
    enable = true;
  };

  # Removed due to required upstream changes
  #
  # programs.glab = {
  #   enable = true;
  # };

  programs.wallust = {
    enable = true;
  };

  # Alternatives to try:
  # wpaperd
  # awww (swww)
  # swaybg

  # programs.wshowkeys = {
  #   enable = true;
  # };

  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true;
  #   dedicatedServer.openFirewall = true;
  #   # localNetworkgameTransfers.openFirewall = true;
  # };

  home.pointerCursor = {
    # name = "Vanilla-DMZ";
    # package = pkgs.vanilla-dmz;
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    enable = true;
    size = 8;
    gtk = {
      enable = true;
    };
  };

  # XDG
  home.preferXdgDirectories = true;
  home.sessionVariables = rec {
    EDITOR = "nvim";
    VISUAL = "nvim";

    XDG_DATA_HOME = "${HOME}\/.local/share";
    XDG_CONFIG_HOME = "${HOME}\/.config";
    XDG_STATE_HOME = "$HOME\/.local/state";
    XDG_CACHE_HOME = "${HOME}\/.cache";
    XDG_DESKTOP_DIR = "${HOME}\/escritorio";
    XDG_DOWNLOAD_DIR = "${HOME}\/descargas";
    XDG_TEMPLATES_DIR = "${HOME}\/plantillas";
    XDG_PUBLICSHARE_DIR = "${HOME}\/público";
    XDG_DOCUMENTS_DIR = "${HOME}\/documentos";
    XDG_MUSIC_DIR = "${HOME}\/música";
    XDG_PICTURES_DIR = "${HOME}\/imágenes";
    XDG_VIDEOS_DIR = "${HOME}\/vídeos";

    # What's the syntax here for defining this?
    # Use `rec`
    HISTFILE = "${XDG_STATE_HOME}\/bash/history";
    PASSWORD_STORE_DIR = "${XDG_DATA_HOME}\/pass";
    PYTHON_HISTORY = "${XDG_STATE_HOME}\/python_history";
    XCOMPOSECACHE = "${XDG_CACHE_HOME}\/X11/xcompose";

  };

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
      xdg-desktop-portal-termfilechooser
    ];

    config = {
      common = {
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
      niri = {
        default = [
          "gtk"
          "gnome"
        ];
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
      };
    };
  };

  xdg.configFile."xdg-desktop-portal-termfilechooser/config" = {
    force = true;
    # enable = true;
    # how can I make this look nicer with an 80 char wrap?
    text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/vifm-wrapper.sh
      default_dir=$HOME/descargas/
      env=TERMCMD=foot
      open_mode=last
      save_mode=suggested
    '';
  };

  # xdg.mimeApps.defaultApplications = {
  #   "text/plain" = ["neovide.desktop"];
  #   "application/pdf" = ["sioyek.desktop"];
  #   "image/*" = ["neovide.desktop"];
  #   "video/png" = ["mpv.desktop"];
  #   "video/jpg" = ["mpv.desktop"];
  #   "video/*" = ["mpv.desktop"];
  # };

  # Git

  # programs.git = {
  #   enable = true;
  #   userName = "";
  #   userEmail = "";
  #   aliases = {
  #     alias1 = "git command1";
  #     alias2 = "git command2";
  #     alias3 = "git command3";
  #   };
  # };

  # Gtk

  # gtk = {
  #   enable = true;
  #   theme.name = "adw-gtk3";
  #   cursorTheme.name = "Bibata-Modern-Ice";
  #   iconTheme.name = "GruvboxPlus";
  # };

  # browsers

  programs.librewolf = {
    enable = true;
    settings = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      "browser.tabs.unloadOnLowMemory" = true;
      "browser.low_commit_space_threshold_percent" = 100;
      "browser.tabs.min_inactive_duration_before_unload" = 3600000;
      "browser.display.screen_resolution" = 0;
      "browser.download.useDownloadDir" = false;
      # "webgl.disabled" = false;
    };

    languagePacks = [
      "es-ES"
      "en-GB"
      "jp"
    ];

    nativeMessagingHosts = with pkgs; [
      tridactyl-native
    ];

    # nativeMessagingHosts = [];

    policies = {
      ExtensionSettings = {

        "tridactyl.vim@cmcaine.co.uk" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        "firefox@betterttv.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/betterttv/latest.xpi";
          installation_mode = "force_installed";
        };

        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
      };
    };
  };

  programs.qutebrowser = {
    enable = true;
    # loadAutoconfig = true;
    settings = {
      colors.webpage.darkmode.enabled = true;
      session.lazy_restore = true;
      input.insert_mode.auto_load = true;
      input.insert_mode.leave_on_load = true;
      qt.highdpi = true;
      window.hide_decoration = true;
      window.transparent = true;
      fonts.default_size = "10pt";
      fonts.web.size = {
        default = 10;
        default_fixed = 10;
        minimum_logical = 6;
      };
      tabs = {
        width = 25;
        # indicator.padding = "";
        favicons.scale = 1.2;
        # how does one pass this table with string values inside?
        # do they need to be escaped?
        # padding = ''{"bottom": 8, "left": 0, "right": 5, "top": 8};'';
        position = "left";
        last_close = "close";
        title.format = "{audio}";
      };
      # editor.command = ["nvim" "-f" "{file}" "-c" "normal {line}G{column0}1"];
      url = {
        default_page = "https://noai.duckduckgo.com/";
        start_pages = [ "https://noai.duckduckgo.com/" ];
      };
    };
    searchEngines = {
      "DEFAULT" = "noai.duckduckgo.com/?q={}";
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };

  programs.fuzzel.enable = true;
  # programs.wikiman.enable = true;

  # we will replace this on the daily once we can reliably reproduce the flake

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      black
      fish-lsp
      gcc
      gdscript-formatter
      gdtoolkit_4
      haskell-language-server
      lua-language-server
      luajitPackages.lua-lsp
      mypy
      prettierd
      pylint
      pyright
      stylua
      typescript-language-server
      yaml-language-server
      # rnix-lsp
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];
  };
}
