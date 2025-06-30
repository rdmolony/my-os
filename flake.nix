{
  description = "Rowan Molony's NixOs Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:numtide/nixpkgs-unfree/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ... 
  }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
    lib = nixpkgs.lib; 
  in {
    homeManagerConfigurations = {
      rowanm = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          "${self}/home.nix"
        ];
        extraSpecialArgs = {
          inherit inputs;
        }; 
      };
    };
    nixosConfigurations = {
      macbook-pro = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/macbook-pro/configuration.nix
        ];
      };
      framework-13 = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/framework-13/configuration.nix
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
        ];
      };
    };  
  };
}
