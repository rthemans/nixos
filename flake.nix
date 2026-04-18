{
  description = "Nixos config flake";

  inputs = {
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
        url = "github:rthemans/dotfiles";
        flake = false;
    };
    hyprland = {
        url = "github:hyprwm/Hyprland";
    };
    modules = {
        url = "path:modules";
        flake = false;
    };
    caelestia-shell = {
        url = "github:caelestia-dots/shell";
    };
  };

  outputs = { self, nixpkgs, unstable, home-manager, caelestia-shell, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
      	inherit system;
        config.allowUnfree = true;
      };
      unstable-pkgs = import unstable {
      	inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
            "libsoup-2.74.3"
        ];
      };
      caelestia-pkgs = caelestia-shell.inputs.nixpkgs.legacyPackages.${system};
      quickshell-caelestia = caelestia-shell.inputs.quickshell.packages.${system}.default;
    in
    {
      nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
          specialArgs = {
              inherit inputs unstable-pkgs quickshell-caelestia;
          };
          modules = [ 
            ./hosts/default/configuration.nix
            home-manager.nixosModules.default
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
