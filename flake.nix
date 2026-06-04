{
  description = "m4tth3 home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHome = system: username: homeDirectory:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          modules = [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ];
        };
    in {
      homeConfigurations = {
        "m4tth3-linux" = mkHome "x86_64-linux" "m4tth3" "/home/m4tth3";
        "m4tth3-mac" = mkHome "aarch64-darwin" "matthew" "/Users/matthew";
      };
    };
}

