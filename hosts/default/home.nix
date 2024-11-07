{ config, pkgs, outputs, lib, ... }:

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
      ".config/omp/config.omp.json".source = ./resources/diamond.omp.json;
      ".config/emacs/init.el".source = ./resources/emacs/init.el;
      ".emacs".source = ./resources/emacs/.emacs;
    };
    
    sessionVariables = {
      
    };
  };

  wayland.windowManager.hyprland = {
    # enable = true;

    settings = {
      "$mod" = "SUPER";

      input = {
        kb_layout = "fr";
        kb_variant = "bepo";
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    tmux = {
      enable = true;
      prefix = "F1";
    };
    wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = ''
        local config = wezterm.config_builder()

        config.color_scheme = 'Atelier Cave Light (base16)'

        return config        
      '';
    };
    home-manager.enable = true;
    emacs = {
      enable = true;
      package = pkgs.emacs;
      extraConfig = ''
      (setq standard-indent 2)
      (setq js-indent-level 2)
      '';
      extraPackages = epkgs: [
        epkgs.nix-mode
        epkgs.json-mode
      ];
    };
    eza = {
      enable = true;
      enableZshIntegration = true;
    };
    zoxide.enable = true;
    fzf.enable = true;
    zsh = {
      enable = true;
      prezto.editor.keymap = "emacs";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initExtra = ''
        eval "$(oh-my-posh init zsh --config ~/.config/omp/config.omp.json)"
        eval "$(zoxide init --cmd cd zsh)"
      '';

      sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/DataDrive/proton/compatibilitytools.d";
      };

      shellAliases = {
        rebuild = "sudo nixos-rebuild switch --flake ~/nixos#default";
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
