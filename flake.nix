{
  description = "Rowan Molony's NixOs Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:numtide/nixpkgs-unfree/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    claude-desktop = {
      url = "path:/home/rowanm/.nixos/flakes/claude-desktop";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
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
          "${self}/users/rowanm/home.nix"
        ];
        extraSpecialArgs = { inherit inputs; packages="${self}/users/rowanm/packages"; }; 
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
        ];
      };
    };  
  };
}
