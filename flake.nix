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
    walker = {
        url = "github:abenz1267/walker";
    };
    hyprland = {
        url = "github:hyprwm/Hyprland";
    };
    modules = {
        url = "path:modules";
        flake = false;
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
      	inherit system;
        config.allowUnfree = true;
      };
      unstable-pkgs = import unstable {
      	inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [ 
            ./hosts/laptop/configuration.nix
	    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
            home-manager.nixosModules.default
          ];
        };
      default = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs unstable-pkgs;};
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
