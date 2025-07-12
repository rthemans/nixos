# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, lib, inputs, outputs, ... }:

let
sddm-astro = pkgs.sddm-astronaut.override { embeddedTheme = "black_hole"; };
jdkEnv = pkgs.runCommand "jdk-env" {
    buildInputs = with pkgs; [
        pkgs.openjdk17
        pkgs.openjdk21
        pkgs.openjdk23
    ];
} ''
mkdir -p $out/jdks
ln -s ${pkgs.openjdk17}/lib/openjdk   $out/jdks/openjdk17
ln -s ${pkgs.openjdk21}/lib/openjdk   $out/jdks/openjdk21
ln -s ${pkgs.openjdk23}/lib/openjdk   $out/jdks/openjdk23
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

# useOSProber = true;
# extraEntriesBeforeNixOS = true;
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

# Enable networking
networking.networkmanager.enable = true;

# fonts
fonts = {
enableDefaultPackages = true;
packages = with pkgs; [
nerd-fonts.roboto-mono
vistafonts
jetbrains-mono
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

programs.hyprland.enable = true;

services.xserver = {
# Enable the X11 windowing system.
    enable = true;

# Nvidia driver
    videoDrivers = ["nouveau"];

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
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "docker" "uinput" "input" ];
    packages = with pkgs; [
        firefox
#  thunderbird
    ];
    shell = pkgs.zsh;
};

home-manager = {
# also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hmbackup";
    users = {
        "rthemans" = import ./home.nix;
    };
};

# Allow unfree packages
nixpkgs.config.allowUnfree = true;
nixpkgs.config.cudaSupport = true;
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
# theme
    pkgs.sleek-grub-theme
    sddm-astro
# wayland
    pkgs.hyprpolkitagent
    pkgs.dbus
# Dev
    pkgs.gradle
    pkgs.bat
    pkgs.nodejs
    pkgs.jetbrains-toolbox
    pkgs.maven
    pkgs.jdk21
    pkgs.jdk17
    pkgs.jdk11
    pkgs.jdk8
    pkgs.godot_4
    pkgs.docker
    pkgs.docker-compose
    pkgs.git
    pkgs.tea
    pkgs.httpie
    pkgs.httpie-desktop
    unstable.neovim

# Utility
    pkgs.flatpak
    pkgs.piper
    pkgs.libratbag
    pkgs.nmon
    pkgs.nvtopPackages.nvidia
    pkgs.masterpdfeditor
    pkgs.wpsoffice
    pkgs.pavucontrol
    pkgs.unzip
    pkgs.pdf-sign
    pkgs.open-pdf-sign
    pkgs.eid-mw
    pkgs.hplipWithPlugin
    pkgs.xdotool
    pkgs.solaar

# Chat
    pkgs.discord

# Productivity
    pkgs.obsidian
    pkgs.keeweb
    unstable.trilium-next-desktop

# Games
## Global
    pkgs.steam-run
    pkgs.protonup
    pkgs.protontricks

## minecraft launcher
    pkgs.prismlauncher

# Other
    pkgs.obs-studio
    pkgs.wget
    pkgs.curl
    pkgs.gvfs
    pkgs.udisks
    pkgs.shutter
    pkgs.openssl
    pkgs.unetbootin

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
