{ config, pkgs, unstable-pkgs, inputs, outputs, lib, ... }:

{

    imports = [
    (import inputs.modules {inherit config inputs pkgs;})
    ];

# Home Manager needs a bit of information about you and the paths it should
# manage.
    home = {
        stateVersion = "23.11"; # never change this!

            username = "rthemans";
        homeDirectory = "/home/rthemans";
        packages = [
            pkgs.gimp
            pkgs.networkmanagerapplet
            pkgs.networkmanager
            pkgs.hplip
            pkgs.librewolf-unwrapped
            pkgs.sioyek
            pkgs.anki
            pkgs.mangohud
            pkgs.gamemode
            pkgs.kdePackages.kdenlive
            pkgs.pastel
        ];

# dotfiles management
        file = {
            ".config/tmux" = {
                source = inputs.dotfiles.outPath + "/tmux";
                recursive = true;
                };
        };

        sessionVariables = {

        };
    };


    wayland.windowManager.hyprland.extraConfig = ''
        # Moniteurs
        monitor = desc:AOC, 1920x1080@239.96, 0x0, 1
        monitor = desc:BNQ, 1920x1080@60.00, 1920x0, 1
        workspace = 1, monitor:desc:AOC
        exec-once = hyprctl dispatch workspace 1

        exec-once = mpvpaper -n 20 -o "--geometry=1920x1060 --shuffle --no-audio" ALL /DataDrive/liveWallpaper/
    '';

# Let Home Manager install and manage itself.
    programs = {
        tmux.enable = true;
        kitty = {
            enable = true;
            extraConfig = ''
                background_opacity 0.9
                '';
            shellIntegration.enableZshIntegration = true;
            themeFile = "Arthur";
        };
        home-manager.enable = true;
        eza = {
            enable = true;
            enableZshIntegration = true;
            icons = "always";
            git = true;
        };
        zoxide.enable = true;
        fzf.enable = true;
        zsh = {
            enable = true;
            enableCompletion = true;
            autosuggestion.enable = true;
            syntaxHighlighting.enable = true;

            initContent = ''
                eval "$(zoxide init --cmd cd zsh)"
                '';

            sessionVariables = {
                STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/DataDrive/proton/compatibilitytools.d";
            };

            shellAliases = {
                rebuild = "sudo nixos-rebuild switch --flake ~/nixos#default";
                rb = "rebuild";
                full-rebuild = "nix flake update && rebuild";
                frb = "full-rebuild";
                switch-bepo = "setxkbmap fr -variant bepo";
                sb = "switch-bepo";
                switch-qwerty = "setxkbmap us";
                sq = "switch-qwerty";
            };
        };
        git = {
            enable = true;
            settings = {
                user = {
                    name = "rthemans";
                    email = "raph.the@gmail.com";
                };

                alias = {
                    cm = "commit -a -m";
                    st = "status -sb";
                    ll = "log --oneline";
                    rv = "remote -v";
                    d = "diff";
                    gl = "config --global -l";
                };

                core = {
                    editor = "nvim";
                };
                help = {
                    autocorrect = "prompt";
                };
                pull = {
                    rebase = true;
                };
            };
        };
        # utils
        oh-my-posh = {
            enable = true;
            enableZshIntegration = true;
            settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./resources/diamond.omp.json));
        };
    };

    services = {
        copyq.enable = true;
    };

    gtk = {
        enable = true;
        iconTheme = {
            name = "WhiteSur";
            package = pkgs.whitesur-icon-theme;
        };
    };

}
