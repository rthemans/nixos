{ config, pkgs, unstable, inputs, outputs, lib, ... }:

{

#  imports = { outputs.homeManagerModules.default }

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

        };

        sessionVariables = {

        };
    };

    wayland.windowManager.hyprland = {
        enable = true;

        settings = {
            exec-once = [
                "exec-once = systemctl --user start hyprpolkitagent"
            ];
            monitor = [
                "Unknown-3, 1920x1080@239.96, 0x0, 1"
                    "Unknown-2, 1920x1080@60.00, 1920x0, 1"
            ];

            input = {
                kb_layout = "fr";
                kb_variant = "bepo";
            };
        };
        extraConfig = ''
            $mod = ALT_SHIFT
            bind = ALT, M, submap, move
            submap = move
            binde = , l, movefocus, r
            binde = , h, movefocus, l
            binde = , j, movefocus, u
            binde = , k, movefocus, d
            bind = , escape, submap, reset
            submap = reset

            bind = $mod, RETURN, exec, kitty
            bind = $mod, Q, killactive,
            bind = $mod, M, exit
            bind = $mod, F, fullscreen, 0
            bind = $mod, L, movefocus, r
            bind = $mod, H, movefocus, l
            bind = $mod, J, movefocus, u
            bind = $mod, K, movefocus, d
            bind = $mod_SHIFT, S, exec, anyrun
            bindm = ALT, mouse:272, movewindow
            bindm = ALT, mouse:272, togglefloating
            '';
    };

# Let Home Manager install and manage itself.
    programs = {
        tmux = {
            enable = true;
            prefix = "M-i";
            keyMode = "vi";
        };
        alacritty = {
            enable = true;
        };
        kitty = {
            enable = true;
            extraConfig = ''
                background_opacity 0.9
                '';
            shellIntegration.enableZshIntegration = true;
            themeFile = "Arthur";
        };
        home-manager.enable = true;
        emacs = {
            enable = true;
            package = pkgs.emacs;
            extraConfig = ''
                (setq standard-indent 2)
                (setq js-indent-level 2)
                (setq display-line-numbers-type 'relative)

                (load-theme 'solarized-light t)
                (use-package fzf
                 ;; :bind
                 ;; Don't forget to set keybinds!
                 :config
                 (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
                  fzf/executable "fzf"
                  fzf/git-grep-args "-i --line-number %s" 
                  ;; command used for `fzf-grep-*` functions
                  ;; example usage for ripgrep:
                  ;; fzf/grep-command "rg --no-heading -nH"
                  fzf/grep-command "grep -nrH"
                  ;; If nil, the fzf buffer will appear at the top of the window
                  fzf/position-bottom t
                  fzf/window-height 15))
                '';
            extraPackages = epkgs: [
                epkgs.nix-mode
                    epkgs.json-mode
                    epkgs.solarized-theme
                    epkgs.fzf
            ];
        };
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
            prezto.editor.keymap = "emacs";
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
                    editor = "emacs";
                };
                help = {
                    autocorrect = "prompt";
                };
                pull = {
                    rebase = true;
                };
            };
        };
        anyrun = {
            enable = true;
            config = {
                x.fraction = 0.5;
                y.fraction = 0.3;
                width.fraction = 0.3;
                hideIcons = false;
                ignoreExclusiveZones = false;
                layer = "top";
                hidePluginInfo = false;
                closeOnClick = false;
                showResultsImmediately = true;
                maxEntries = null;
                plugins = [
                    inputs.anyrun.packages.${pkgs.system}.applications
                    inputs.anyrun.packages.${pkgs.system}.rink
                ];
            };
        };
        oh-my-posh = {
            package = unstable.oh-my-posh;
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

# dconf settings
    dconf.settings = {
        "org/buddiesofbudgie/budgie-desktop-view" = {
            show = false;
        };

        "com/solus-project/budgie-wm" = {
            button-style = "left";
            button-layout = "close,minimize,maximize:appmenu";
        };

    };
}
