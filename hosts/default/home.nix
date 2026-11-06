{ config, pkgs, inputs, outputs, lib, ... }:

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
# others
            pkgs.citrix_workspace
            pkgs.gimp
            pkgs.networkmanagerapplet
            pkgs.networkmanager
            pkgs.qutebrowser
            pkgs.mangohud
            pkgs.gamemode
            pkgs.kdePackages.kdenlive
            pkgs.pastel
            pkgs.aseprite
            pkgs.openclaw
            pkgs.gogcli
# Dev
            pkgs.opencode
            pkgs.bat
            pkgs.godot
            pkgs.docker
            pkgs.docker-compose
            pkgs.git
            pkgs.httpie
            pkgs.zig
            pkgs.neovim
            pkgs.kdePackages.qtdeclarative
            pkgs.nil

# Utility
            pkgs.signal-desktop
            pkgs.sops
            pkgs.keepassxc
            pkgs.davfs2
            pkgs.atril
            pkgs.caja
            pkgs.ripgrep
            pkgs.mpvpaper
            pkgs.wlroots_0_19
            pkgs.vlc
            pkgs.qimgv
            pkgs.nmon
            pkgs.pavucontrol
            pkgs.unzip
            pkgs.eid-mw
            pkgs.python314
            pkgs.python314Packages.weasyprint

# Chat
            pkgs.discord
# Games
## minecraft launcher
            pkgs.prismlauncher
            pkgs.heroic
            pkgs.gogdl
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
        hl.monitor({ output = "desc:AOC", mode = "1920x1080@239.96", position = "0x0", scale = 1 })
        hl.monitor({ output = "desc:BNQ", mode = "1920x1080@60.00", position = "1920x0", scale = 1 })
        hl.workspace_rule({ workspace = "1", monitor = "desc:AOC" })
        hl.on("hyprland.start", function()
            hl.dispatch(hl.dsp.focus({ workspace = "1" }))
            hl.exec_cmd("mpvpaper -n 20 -o '--geometry=1920x1060 --shuffle --no-audio' ALL /DataDrive/liveWallpaper/current/")
        end)
    '';

# Let Home Manager install and manage itself.
    programs = {
        tmux.enable = true;
        kitty = {
            enable = true;
            extraConfig = ''
                background_opacity 0.9
                term xterm-256color
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
                path+=("/home/rthemans/.mammouth/bin")
                export PATH
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
                safe = {
                    directory = "*";
                };
            };
        };
        # utils
        oh-my-posh = {
            enable = true;
            enableZshIntegration = true;
            settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./resources/diamond.omp.json));
        };
        quickshell = {
            enable = true;
        };
    };

    services = {
        copyq.enable = true;
    };

    gtk = {
        enable = true;
# adopte le nouveau défaut de home-manager 26.05 (comportement identique ici)
        gtk4.theme = null;
        iconTheme = {
            name = "WhiteSur";
            package = pkgs.whitesur-icon-theme;
        };
    };

}
