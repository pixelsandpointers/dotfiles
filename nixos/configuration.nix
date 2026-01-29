# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  ns = pkgs.writeShellScriptBin "ns" (builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh");
  DGPU = "/dev/dri/card1";
  IGPU = "/dev/dri/card2";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      efi.canTouchEfiVariables = true;
    };

    # Kernel modules for Asus I2C touchpad
    kernelModules = [ "hid-multitouch" "hid-asus" "i2c-hid-acpi" ];

    # Kernel parameters for touchpad support
    kernelParams = [
      "i2c_hid.dyndbg=+p"  # Enable debug for i2c_hid
      "hid_asus.enable=1"   # Enable hid-asus driver
    ];

    # Blacklist hid-generic for the Asus touchpad device to force hid-asus
    blacklistedKernelModules = [ "hid-generic" ];
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      max-jobs = "auto";
      cores = 0;

      substituters = [
        "https://cuda-maintainers.cachix.org"
      ];

      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };


  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    # this would require all packages that may have a dependency for CUDA to build CUDA from source >:|
    #cudaSupport = true;
  };

  users.users.ben = {
    isNormalUser = true;
    description = "ben";
    extraGroups = [ "networkmanager" "wheel" "docker" "audio" ];
    shell = pkgs.zsh;
  };

  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    # https://nixos.wiki/wiki/Nvidia
    nvidia = {
      open = false; # only from RTX 20xx onward
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      nvidiaSettings = true;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        amdgpuBusId = "PCI:7:0:0";    # from 07:00.0  (your Cezanne iGPU)
        nvidiaBusId = "PCI:1:0:0";    # from 01:00.0  (your RTX 3070 Mobile)
      };
    };
  };

  services = {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        naturalScrolling = false;
        disableWhileTyping = true;
      };
    };
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" "nvidia" ];
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "altgr-intl";
      };
    };
    displayManager = {
      sddm.enable = true;
    };

    # Enable the KDE Plasma Desktop Environment.
    desktopManager.plasma6.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pulseaudio.package = pkgs.pulseaudioFull;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
      #
      # wireplumber.extraConfig.bluetoothEnhancements = {
      #   "monitor.bluez.properties" = {
      #     "bluez5.enable-sbc-xq" = true;
      #     "bluez5.enable-msbc" = true;
      #     "bluez5.enable-hw-volume" = true;
      #     "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      #   };
      # };
    };

    udev.extraRules = ''
      # Asus I2C Touchpad - force hid-asus driver
      ATTRS{name}=="ASUS2020:00 0B05:0220", RUN+="${pkgs.kmod}/bin/modprobe hid-asus", RUN+="${pkgs.bash}/bin/sh -c 'echo 0018:0B05:0220.0001 > /sys/bus/hid/drivers/hid-generic/unbind; echo 0018:0B05:0220.0001 > /sys/bus/hid/drivers/hid-asus/bind'"

      # Rules for Oryx web flashing and live training
KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

# Legacy rules for live training over webusb (Not needed for firmware v21+)
  # Rule for all ZSA keyboards
  SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
  # Rule for the Moonlander
  SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
  # Rule for the Ergodox EZ
  SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
  # Rule for the Planck EZ
  SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

# Wally Flashing rules for the Ergodox EZ
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

# Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
# Keymapp Flashing rules for the Voyager
SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
      '';
  };

  # Enable networking
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;

      # TUDa VPN (manage over the UI, might want to change later)
      plugins = with pkgs; [
        networkmanager-openconnect
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n = {
    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
          qt6Packages.fcitx5-chinese-addons
          kdePackages.fcitx5-configtool
        ];
      };
    };    
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.blex-mono
    libertine
  ];

  security.rtkit.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [

    # Nix tooling
    cachix
    devenv
    devbox
    direnv
    fh
    nix-search-tv
    nix-tree
    nixpkgs-fmt
    nh
    ns
    nixd

    # CLI
    autoconf
    bat
    btop
    btop-cuda
    chafa
    cmake
    curl
    dwt1-shell-color-scripts
    fd
    ffmpeg
    fzf
    gh
    git
    git-lfs
    gnumake
    imagemagick
    lazygit
    libinput
    pciutils
    pkg-config
    ripgrep
    tmux
    tree-sitter
    unzip
    virtualgl
    vulkan-tools
    wget
    yazi
    zoxide

    # messenger
    discord
    element-desktop
    signal-desktop

    # other apps
    anki-bin
    brave
    darktable
    cider-2
    ghostty
    houdini
    filezilla
    mpv
    moonlight-qt
    obsidian
    openconnect
    renderdoc
    vlc
    zoom-us
    zotero

    # KDE extensions
    rclone
    kdePackages.partitionmanager

    # development
    blender
    claude-code
    godotPackages_4_5.godot
    jetbrains-toolbox
    vscode

    # gaming
    mangohud
    protonup-ng

    # audio
    pulseaudioFull
    pulsemixer
    easyeffects

    stdenv.cc
    cudaPackages.nsight_systems
    cudaPackages.nsight_compute
    cudaPackages.cudatoolkit
    cudaPackages.cuda_cudart
    nvtopPackages.full
    perf
  ];

  environment.sessionVariables = {
    KWIN_DRM_DEVICES = lib.mkDefault "/dev/dri/card1:/dev/dri/card2"; # prioritise the first card (GPU)
    STEAM_EXTRA_COMPAT_TOOLS_PATH = "/home/ben/.steam/root/compatibilitytools.d";
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
    # this should be done using patchelf
    # LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };

  # environment.extraInit = ''
  #   export LD_LIBRARY_PATH=/run/opengl-driver/lib:$LD_LIBRARY_PATH
  # '';

  programs = {
    xwayland.enable = true;
    gamemode.enable = true;
    chromium.enable = true;
    thunderbird.enable = true;

    zsh = {
      enable = true;
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      withNodeJs = true;
      vimAlias = true;
      viAlias = true;
    };

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        cudaPackages.cudatoolkit
      ];
    };
  };

  virtualisation = {
    docker.enable = true;
  };

  specialisation.ac.configuration = {
    environment.sessionVariables.KWIN_DRM_DEVICES = "${DGPU}:${IGPU}";
  };

  specialisation.battery.configuration = {
    environment.sessionVariables.KWIN_DRM_DEVICES = "${IGPU}:${DGPU}";
  };


  # Systemd
  systemd.tmpfiles.rules = [
    "d /home/ben/gdrive 0755 ben users -"
    "d /home/ben/Vault 0755 ben users -"
  ];

  systemd.services.rclone-drive-mount = {
    description = "Mount Google Drive with rclone";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "notify";
      User = "ben";
      Group = "users";
      Environment = [
        "PATH=/run/wrappers/bin:${pkgs.rclone}/bin"
      ];
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/ben/gdrive";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount gdrive: /home/ben/gdrive \
        --vfs-cache-mode writes \
        --vfs-cache-max-age 24h \
        --vfs-write-back 5s \
        --buffer-size 256M \
        --dir-cache-time 24h \
        --poll-interval 15s \
        --allow-non-empty \
        --log-file=/home/ben/.cache/rclone-mount.log \
        --log-level=INFO
      '';
      ExecStop = "${pkgs.util-linux}/bin/fusermount -u /home/ben/gdrive";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  systemd.services.rclone-vault-mount = {
    description = "Mount Obsidian Vault with full offline caching";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "notify";
      User = "ben";
      Group = "users";
      Environment = [
        "PATH=/run/wrappers/bin:${pkgs.rclone}/bin"
      ];
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/ben/Vault";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount gdrive:/Vault /home/ben/Vault \
        --vfs-cache-mode full \
        --vfs-cache-max-age 168h \
        --vfs-cache-max-size 5G \
        --vfs-write-back 5s \
        --buffer-size 256M \
        --dir-cache-time 24h \
        --poll-interval 15s \
        --allow-non-empty \
        --log-file=/home/ben/.cache/rclone-vault-mount.log \
        --log-level=INFO
      '';
      ExecStop = "${pkgs.util-linux}/bin/fusermount -u /home/ben/Vault";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
