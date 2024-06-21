# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, outputs, ... }:

let
  grub-theme = pkgs.stdenv.mkDerivation {
      pname = "sleek-grub-theme";
      version = "unstable-2022-06-04";

      src = pkgs.fetchFromGitHub ({
        owner = "sandesh236";
        repo = "sleek--themes";
        rev = "981326a8e35985dc23f1b066fdbe66ff09df2371";
        hash = "sha256-yD4JuoFGTXE/aI76EtP4rEWCc5UdFGi7Ojys6Yp8Z58=";
      });

      installPhase = ''
        runHook preInstall

        mkdir -p $out/

        cp -r 'Sleek theme-bigSur'/sleek/* $out/
        sed -i "s/Grub Bootloader/Bonjour Raphael/" $out/theme.txt

        runHook postInstall
      '';
    };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  boot.loader.grub = {
    enable = true;
    gfxmodeEfi = "1920x1080";
    gfxmodeBios = "1920x1080";
    
    device = "/dev/sdb";

    theme = lib.mkForce grub-theme;

    # useOSProber = true;
    # extraEntriesBeforeNixOS = true;
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  nix.optimise = {
    automatic = true;
    dates = [ "21:00" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      xorg.xfontsel
      jetbrains-mono
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
      noto-fonts
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrains Mono Medium" ];
      };
    };
  };

  # Enable network manager applet
  programs.nm-applet.enable = true;

  # Enable steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_BE.UTF-8";
    LC_IDENTIFICATION = "fr_BE.UTF-8";
    LC_MEASUREMENT = "fr_BE.UTF-8";
    LC_MONETARY = "fr_BE.UTF-8";
    LC_NAME = "fr_BE.UTF-8";
    LC_NUMERIC = "fr_BE.UTF-8";
    LC_PAPER = "fr_BE.UTF-8";
    LC_TELEPHONE = "fr_BE.UTF-8";
    LC_TIME = "fr_BE.UTF-8";
  };

  console.useXkbConfig = true;

  services.displayManager = {
    # Enable automatic login for the user.
    autoLogin = {
      enable = true;
      user = "rthemans";
    };

    sddm = {
      enable = true;
      autoNumlock = true;
    };
  };
  
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Nvidia driver
    videoDrivers = ["displayLink" "nvidia"];
    
    # Configure keymap in X11    
    xkb.layout = "fr";
    xkb.variant = "bepo";
    
    desktopManager.budgie.enable = true;

    # setup monitors
    # I don't think that's working though
    xrandrHeads = ["DP-3-2" "DP-3-3"];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];

  # enable zsh at system level
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rthemans = {
    isNormalUser = true;
    description = "rthemans";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "docker" ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    users = {
      "rthemans" = import ./home.nix;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    masterpdfeditor
    wpsoffice
    oh-my-posh
    pavucontrol
    unzip
    jetbrains-toolbox
    maven
    jdk11
    pdf-sign
    open-pdf-sign
    eid-mw
    hplipWithPlugin
    godot_4
    docker
    docker-compose
    wget
    curl
    git
    obsidian
    keepassxc
    gvfs
    udisks
    shutter
    xboxdrv
    tea
    openssl
    unetbootin
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # enable usb
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  virtualisation.docker.enable = true;
}
