{
  description = "m4tth3 home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Multi-target Rust toolchain. nixpkgs' rustc ships host std only, so it
    # can't cross-compile to Linux from macOS. fenix lets us pull in the
    # x86_64-unknown-linux-gnu rust-std alongside the host toolchain.
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, fenix, ... }:
    let
      mkHome = system: username: homeDirectory:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ fenix.overlays.default ];
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

