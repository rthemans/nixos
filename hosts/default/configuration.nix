# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, unstable-pkgs, pkgs, lib, inputs, outputs, ... }:

let
sddm-astro = pkgs.sddm-astronaut.override { embeddedTheme = "black_hole"; };
jdkEnv = pkgs.runCommand "jdk-env" {
    buildInputs = with pkgs; [
        pkgs.openjdk17
        pkgs.openjdk21
    ];
} ''
mkdir -p $out/jdks
ln -s ${pkgs.openjdk17}/lib/openjdk   $out/jdks/openjdk17
ln -s ${pkgs.openjdk21}/lib/openjdk   $out/jdks/openjdk21
'';
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

        theme = pkgs.sleek-grub-theme.override { withBanner = "Bonjour Raphael!!"; withStyle = "bigSur"; };
    };

    networking.hostName = "default"; # Define your hostname.
    #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

        nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
            trusted-users = [ "root" "rthemans" ];
            substituters = ["https://hyprland.cachix.org"];
            trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
        };

    nix.optimise = {
        automatic = true;
        dates = [ "21:00" ];
    };

    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 15d";
    };

    programs.nix-ld.enable = true;

# Enable networking
    networking.networkmanager.enable = true;

# fonts
    fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
            roboto
                open-fonts
                open-sans
                nerd-fonts.roboto-mono
                nerd-fonts.caskaydia-mono
                nerd-fonts.symbols-only
                nerd-fonts.fira-code
                nerd-fonts.monofur
                inter-nerdfont
        ];

        fontconfig = {
            defaultFonts = {
                monospace = [ "RobotoMono Nerd Font Mono" ];
                emoji = [ "Symols Nerd Font" ];
            };
        };
    };

# Enable network manager applet
programs.nm-applet.enable = true;
programs.ssh.startAgent = true;

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
    autoLogin = {
        enable = true;
        user = "rthemans";
    };
# displays the lockscreen through ssdm
    sddm = {
        enable = true;
        autoNumlock = false;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        package = pkgs.kdePackages.sddm;
        extraPackages = [
        sddm-astro
        ];
    };
};

programs.hyprland = {
    enable = true;
};

services.xserver = {
# Enable the X11 windowing system.
    enable = false;

# Nvidia driver
    videoDrivers = ["nvidia"];

# Configure keymap in X11    
    xkb.layout = "fr";
    xkb.variant = "bepo";
    exportConfiguration = true;
};

# Enable CUPS to print documents.
services.printing.enable = true;

# Enable sound with pipewire.
security.rtkit.enable = true;

services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
};
systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];

# bluetooth cli
services.blueman.enable = true;

# enable zsh at system level
programs.zsh.enable = true;

# Define a user account. Don't forget to set a password with ‘passwd’.
users.mutableUsers = false;
users.users.rthemans = {
    hashedPassword = "$y$j9T$zQYPCbLq8..vy/I3DUCTT0$LD9Z4byg1OC/EG40TfdAu.tLEqiogZPG7iJw7wLwGXC";
    isNormalUser = true;
    description = "rthemans";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "docker" "uinput" "input" "render" "video" "davfs2" ];
    packages = with pkgs; [
        firefox
        libnotify
        networkmanagerapplet
    ];
    shell = pkgs.zsh;
};

home-manager = {
# also pass inputs to home-manager modules
    extraSpecialArgs = { inherit unstable-pkgs inputs; };
    backupFileExtension = "hmbackup";
    users = {
        "rthemans" = import ./home.nix;
    };
};

# Allow unfree packages
nixpkgs.config.allowUnfree = true;
nixpkgs.config.nvidia.acceptLicense = true;
nixpkgs.config.cudaSupport = false;
# setup for jdks
environment.pathsToLink = [ "/jdks" ];
system.activationScripts.jdkSymlinks.text = ''
mkdir -p /opt
chmod 755 /opt

ln -sfT /run/current-system/sw/jdks /opt/java
'';

# List packages installed in system profile. To search, run:
# $ nix search wget
environment.systemPackages = [
# variable
    jdkEnv
    pkgs.jdk21
    pkgs.jdk17
    pkgs.jdk11
    pkgs.jdk8
# theme
    pkgs.sleek-grub-theme
    sddm-astro

# Other
    pkgs.wget
    pkgs.curl
    pkgs.gvfs
    pkgs.udisks
    pkgs.shutter
    pkgs.openssl
    pkgs.unetbootin
    pkgs.pulseaudio
    pkgs.hplipWithPlugin

# Machine Learning
    pkgs.cachix
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

programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  gamescopeSession.enable = true;
};
programs.gamescope = {
    enable = true;
    capSysNice = true;
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

services.flatpak.enable = false;
services.davfs2.enable = true;

virtualisation.docker.enable = true;

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets."webdav_airthems" = {
        sopsFile = ../../secrets/webdav.yaml;
        mode = "0600";
        path = "/etc/davfs2/secrets";
    };
  };

  systemd.tmpfiles.rules = [ "d /mnt/webdav 0755 root root - -" ];
  systemd.mounts = [
  {
    enable = true;
    description = "Webdav mount point";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  
    what = "https://webdav.airthems.org";
    where = "/mnt/webdav";
    wantedBy = [ "multi-user.target" ];
    options = "uid=1000,gid=100,file_mode=0664,dir_mode=2775,_netdev";
    type = "davfs";
    mountConfig.TimeoutSec = 15;
  }
  ];
}
