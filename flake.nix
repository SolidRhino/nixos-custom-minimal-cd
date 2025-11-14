{
  description = "Custom minimal NixOS installation ISO with enhanced tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    t2-iso = {
      url = "github:t2linux/nixos-t2-iso";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems to build for
      # ISOs only build on Linux, but dev tools work on Darwin too
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Import flake-parts modules
      imports = [
        ./flake-parts/iso.nix
        ./flake-parts/t2-iso.nix
      ];
    };
}
