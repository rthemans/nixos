{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
        url = "github:rthemans/dotfiles";
        flake = false;
    };
    hyprland = {
        url = "github:hyprwm/Hyprland/v0.54.3-b";
    };
    modules = {
        url = "path:modules";
        flake = false;
    };
    caelestia-shell = {
        url = "github:caelestia-dots/shell";
    };
    sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, caelestia-shell, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
      	inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
          specialArgs = {
              inherit inputs;
          };
          modules = [ 
          {
              nixpkgs.config.doCheckByDefault = false;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.permittedInsecurePackages = [
                  "libsoup-2.74.3"  # Requis par citrix-workspace
              ];
          }
            ./hosts/default/configuration.nix
            home-manager.nixosModules.default
            sops-nix.nixosModules.sops
          ];
        };
      server = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [ 
            ./hosts/server/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
      };
    };
}
