{
  description = "Rowan Molony's NixOs Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    tiddlydesktop.url = "github:rdmolony/TiddlyDesktop/parametrise-nixpkgs";
    tiddlydesktop.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    home-manager,
    tiddlydesktop,
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
          ./users/rowanm/home.nix
        ];
        extraSpecialArgs = { inherit inputs; }; 
      };
    };
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/configuration.nix
        ];
      };
    };  
  };
}
