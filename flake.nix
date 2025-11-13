{
  description = "Custom minimal NixOS installation ISO with enhanced tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixvim }: {
    nixosConfigurations = {
      # x86_64 ISO configuration
      x86_64-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          nixvim.nixosModules.nixvim
          ./configuration.nix
        ];
      };

      # aarch64 (ARM64) ISO configuration
      aarch64-iso = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          nixvim.nixosModules.nixvim
          ./configuration.nix
        ];
      };
    };
  };
}
