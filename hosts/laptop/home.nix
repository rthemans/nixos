{ config, pkgs, inputs, outputs, lib, ... }:

{

#  imports = { outputs.homeManagerModules.default }
    imports = [
        inputs.walker.homeManagerModules.default
    ];

# Home Manager needs a bit of information about you and the paths it should
# manage.
    home = {
        stateVersion = "25.05"; # never change this!

            username = "rthemans";
        homeDirectory = "/home/rthemans";
        packages = [
        ];

# dotfiles management
        file = {
            ".config/" = { source = inputs.dotfiles; recursive = true; };
        };

        sessionVariables = {

        };
    };

    wayland.windowManager.hyprland.enable = false;


# Let Home Manager install and manage itself.
    programs = {
        mpv.enable = true;
        hyprlock.enable = true;
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
                rebuild = "sudo nixos-rebuild switch --flake ~/nixos#laptop";
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
            userName = "rthemans";
            userEmail = "raph.the@gmail.com";

            aliases = {
                cm = "commit -a -m";
                st = "status -sb";
                ll = "log --oneline";
                rv = "remote -v";
                d = "diff";
                gl = "config --global -l";
            };

            extraConfig = {
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
        # wayland stuff
        walker = {
            enable = false;
            runAsService = true;

# All options from the config.json can be used here.
            config = {
                search.placeholder = "Example";
                ui.fullscreen = true;
                list = {
                    height = 200;
                };
                websearch.prefix = "?";
                switcher.prefix = "/";
            };

        };
        waybar.enable = false;
        # utils
        oh-my-posh = {
            enable = true;
            enableZshIntegration = true;
            settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./resources/diamond.omp.json));
        };
    };

    services = {
        copyq.enable = true;
        #hyprpaper.enable = true;
    };

    gtk = {
        enable = true;

        theme = lib.mkForce {
            package = pkgs.whitesur-gtk-theme;
            name = "WhiteSur-Light";
        };

        cursorTheme = {
            package = pkgs.whitesur-cursors;
            name = "WhiteSur-cursors";
        };

        iconTheme = {
            name = "WhiteSur";
            package = pkgs.whitesur-icon-theme;

        };
    };

}
