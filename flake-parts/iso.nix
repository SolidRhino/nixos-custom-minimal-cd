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
  perSystem = { system, pkgs, lib, ... }:
    let
      isLinux = lib.hasSuffix "-linux" system;
    in
    {
      # ISO packages only available on Linux systems
      packages = lib.optionalAttrs isLinux {
        # Main ISO package - builds for the current system
        iso = mkIso system;

        # Default package points to iso
        default = mkIso system;
      };

      # Formatter available on all systems (including Darwin)
      formatter = pkgs.nixpkgs-fmt;
    };
}
