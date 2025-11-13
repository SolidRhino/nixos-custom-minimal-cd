{
  description = "Custom minimal NixOS installation ISO with enhanced tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      # x86_64 ISO configuration
      x86_64-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./configuration.nix
        ];
      };

      # aarch64 (ARM64) ISO configuration
      aarch64-iso = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./configuration.nix
        ];
      };
    };
  };
}
