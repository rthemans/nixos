{ config, pkgs, inputs, outputs, lib, ... }:

{

#  imports = { outputs.homeManagerModules.default }
    imports = [
        inputs.walker.homeManagerModules.default
    ];

# Home Manager needs a bit of information about you and the paths it should
# manage.
    home = {
        stateVersion = "23.11"; # never change this!

            username = "rthemans";
        homeDirectory = "/home/rthemans";
        packages = [
        ];

# dotfiles management
        file = {
            ".config/" = {
                source = inputs.dotfiles;
                recursive = true;
                };
            ".config/hypr" = {
                source = ./resources/hypr;
                recursive = true;
                };
        };

        sessionVariables = {

        };
    };

    wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = ''
            source = setup.conf
            source = settings.conf
            source = nvim-binds.conf
            source = rules.conf
        '';
    };


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
        # wayland stuff
        walker = {
            enable = true;
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
        waybar.enable = true;
        # utils
        oh-my-posh = {
            enable = true;
            enableZshIntegration = true;
            settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./resources/diamond.omp.json));
        };
    };

    services = {
        copyq.enable = true;
        swaync = {
            enable = true;
        };
    };

    gtk = {
        enable = true;
        iconTheme = {
            name = "WhiteSur";
            package = pkgs.whitesur-icon-theme;
        };
    };

}
