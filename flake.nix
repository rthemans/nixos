{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixunspkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun = {
        url = "github:anyrun-org/anyrun";
        inputs.nixpkgs.follows = "nixunspkgs";
    };
  };

  outputs = { self, nixpkgs, nixunspkgs, anyrun, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
      	inherit system;
	config.allowUnhree = true;
      };
      unstable = import nixunspkgs {
      	inherit system;
	config.allowUnhree = true;
      };
    in
    {
      nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [ 
            ./hosts/default/configuration.nix
	    {
            environment.systemPackages = [ anyrun.packages.${system}.anyrun ];
		    _module.args = { inherit unstable; };
	    }
            inputs.home-manager.nixosModules.default {
	    	home-manager.extraSpecialArgs = { inherit unstable; } ;
	    }
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
