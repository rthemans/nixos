# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, outputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  boot.loader.grub = {
    enable = true;
    
    device = "/dev/sda";
    extraEntries = ''
      menuentry "Windows 10" {
      chainloader (hd0,1)+1
    }
    '';

    # useOSProber = true;
    # extraEntriesBeforeNixOS = true;
  };

  # init shell: alias then variables
  environment.interactiveShellInit = ''
    alias rebuild-default='sudo nixos-rebuild switch --flake /home/rthemans/nixos#default --impure'
    
    export EDITOR=emacs;
    eval "$(zoxide init --cmd cd bash)"
  '';

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable network manager applet
  programs.nm-applet.enable = true;

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

  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;
  
  systemd.services."jellyfin".serviceConfig = {
    DeviceAllow = pkgs.lib.mkForce [ "char-drm rw" "char-nvidia-frontend rw" "char-nvidia-uvm rw" ];
    PrivateDevices = pkgs.lib.mkForce true;
    RestrictAddressFamilies = pkgs.lib.mkForce [ "AF_UNIX" "AF_NETLINK" "AF_INET" "AF_INET6" ];
};
  
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Nvidia driver
    videoDrivers = ["displayLink"];
    
    # Configure keymap in X11    
    xkb.layout = "fr";
    xkb.variant = "bepo";

    displayManager = {
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
  security.pki.certificateFiles = [
    /home/rthemans/certs/geotrust-rsa-ca.crt
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rthemans = {
    isNormalUser = true;
    description = "rthemans";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "docker" ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
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

  # jellyfin config
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    quickemu
    quickgui
    netcat-gnu
    wezterm
    hplipWithPlugin
    abiword
    teams-for-linux
    godot_4
    docker
    docker-compose
    wget
    curl
    whitesur-gtk-theme
    git
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    lutris
    obsidian
    keepassxc
    gvfs
    udisks
    shutter
    xboxdrv
    wine
    google-chrome
    tea
    openssl
    tmux
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
