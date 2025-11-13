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
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems to build for
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # Import flake-parts modules
      imports = [
        ./flake-parts/iso.nix
      ];
    };
}
