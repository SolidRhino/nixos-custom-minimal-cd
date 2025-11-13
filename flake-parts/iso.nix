{ inputs, self, ... }:

let
  # Helper function to create ISO for a system
  mkIso = system:
    (inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        inputs.nixvim.nixosModules.nixvim
        "${self}/configuration.nix"
      ];
    }).config.system.build.isoImage;
in
{
  perSystem = { system, ... }: {
    packages = {
      # Main ISO package - builds for the current system
      iso = mkIso system;

      # Default package points to iso
      default = mkIso system;
    };
  };

  # Keep nixosConfigurations for backward compatibility and GitHub Actions
  flake.nixosConfigurations = {
    x86_64-iso = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        inputs.nixvim.nixosModules.nixvim
        "${self}/configuration.nix"
      ];
    };

    aarch64-iso = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        inputs.nixvim.nixosModules.nixvim
        "${self}/configuration.nix"
      ];
    };
  };
}
