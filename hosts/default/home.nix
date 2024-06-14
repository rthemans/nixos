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
    };
    
    sessionVariables = {
    
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    emacs = {
      enable = true;
      package = pkgs.emacs;
      extraConfig = ''
      (setq standard-indent 2)
      '';
    };
    zoxide.enable = true;
    fzf.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initExtra = ''
        eval "$(oh-my-posh init zsh)"
	eval "$(zoxide init --cmd cd zsh)"
      '';

      shellAliases = {
        rebuild = "sudo nixos-rebuild switch --flake ~/nixos#default";
      };
    };
    git = {
      enable = true;
      userName = "rthemans";
      userEmail = "raph.the@gmail.com";
      extraConfig = {
        safe = {
	  directory = "*";
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
