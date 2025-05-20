{
  description = "A very basic flake";

  inputs = {

    # TODO: PIN IT
    nixpkgs.url = "github:nixos/nixpkgs";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    apple-silicon-support = {
      # TODO: PIN IT
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Don't touch their nixpkgs :)
    hyprland.url = "github:hyprwm/Hyprland";

    # TODO: PIN
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = { 
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, apple-silicon-support, home-manager, ... }@inputs: 
  let
    system = "aarch64-linux";
  in
  {
    formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;

    nixosConfigurations = {
      mainm1 = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/mainm1/configuration.nix
          apple-silicon-support.nixosModules.default
        ];
      };
    };

    homeConfigurations = {
      "phitch@mainm1" = home-manager.lib.homeManagerConfiguration {
         pkgs = nixpkgs.legacyPackages.${system};
         extraSpecialArgs = { inherit inputs; };
         modules = [
           ./home/phitch/home.nix
         ];
       };
    };

  };
}
