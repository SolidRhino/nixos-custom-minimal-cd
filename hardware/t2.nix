{ config, pkgs, lib, nixos-hardware, ... }:

let
  firmware-script = pkgs.callPackage ../flake-parts/pkgs/firmware-script.nix { };
in
{
  # Import apple-t2 hardware module (kernel patches, drivers, T2 config)
  imports = [ nixos-hardware.nixosModules.apple-t2 ];

  # T2 binary caches (three-line pattern for max compatibility)
  nix.settings = {
    extra-trusted-substituters = [
      "https://t2linux.cachix.org"
      "https://cache.soopy.moe"
    ];
    extra-substituters = [
      "https://t2linux.cachix.org"
      "https://cache.soopy.moe"
    ];
    extra-trusted-public-keys = [
      "t2linux.cachix.org-1:P1TzTMk1US9G4Q7+8NpfnzYz3LU6iYY3D8L1u9mD6P8="
      "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="
    ];
  };

  # T2-specific tools
  environment.systemPackages = with pkgs; [
    python3          # Required by firmware script
    dmg2img          # Converts macOS disk images
    firmware-script  # Extracts WiFi/Bluetooth firmware from macOS
  ];

  # Platform constraint: T2 Macs are x86_64 only
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
