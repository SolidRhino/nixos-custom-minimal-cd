{ inputs, self, ... }:

let
  # Helper function to create T2 ISO for x86_64-linux
  # T2 Macs only support x86_64 architecture
  mkT2Iso = system:
    (inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit (inputs) nixos-hardware;
      };
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        inputs.nixvim.nixosModules.nixvim
        "${self}/configuration.nix"
        "${self}/hardware/t2.nix"
      ];
    }).config.system.build.isoImage;
in
{
  perSystem = { system, pkgs, lib, ... }:
    {
      # T2 ISO only available for x86_64-linux
      # T2 Macs are Intel-based and do not support ARM
      packages = lib.optionalAttrs (system == "x86_64-linux") {
        iso-t2 = mkT2Iso system;
      };
    };
}
