{ inputs, self, ... }:

{
  perSystem = { system, pkgs, lib, ... }:
    {
      # T2 ISO only available for x86_64-linux
      # T2 Macs are Intel-based (2018-2020 models)
      packages = lib.optionalAttrs (system == "x86_64-linux") {
        iso-t2 = (lib.nixosSystem {
          inherit system;
          modules = [
            # Base T2 ISO from t2linux (includes apple-t2 module, firmware tools, binary caches)
            {
              imports = [
                "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                inputs.t2-iso.nixosModules.apple-t2
              ];

              # T2 binary caches (from t2linux)
              nix.settings = {
                trusted-substituters = [ "https://t2linux.cachix.org" ];
                trusted-public-keys = [ "t2linux.cachix.org-1:P733c5Gt1qTcxsm+Bae0renWnT8OLs0u9+yfaK2Bejw=" ];
                experimental-features = [ "nix-command" "flakes" ];
              };

              # T2 firmware extraction tools
              environment.systemPackages = with pkgs; [
                git
                python3
                dmg2img
                (pkgs.callPackage "${inputs.t2-iso}/nix/pkgs/firmware-script.nix" { })
              ];

              nixpkgs.hostPlatform = "x86_64-linux";
            }

            # Custom editor configurations
            inputs.nixvim.nixosModules.nixvim
            "${self}/editors/helix.nix"
            "${self}/editors/neovim.nix"

            # Custom system configuration
            "${self}/configuration.nix"

            # Override ISO filename to create unique derivation
            {
              image.fileName = lib.mkForce "nixos-minimal-x86_64-t2-custom.iso";
            }
          ];
        }).config.system.build.isoImage;
      };
    };
}
