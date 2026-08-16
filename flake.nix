{
  description = "m4tth3 home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust toolchains with extra targets — nixpkgs' rustc ships host std only,
    # so it can't cross-compile to Linux from macOS
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, fenix, ... }:
    let
      mkHome = { system, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ fenix.overlays.default ];
          };
          modules = [ ./home.nix ] ++ modules;
        };
    in {
      # Keyed by username: a bare `home-manager switch` resolves
      # "$USER@$hostname" then "$USER", so no `--flake .#name` needed
      homeConfigurations = {
        "m4tth3" = mkHome {
          system = "x86_64-linux";
          modules = [ ./users/m4tth3.nix ];
        };
        "matthew" = mkHome {
          system = "aarch64-darwin";
          modules = [ ./users/matthew.nix ];
        };
      };
    };
}
