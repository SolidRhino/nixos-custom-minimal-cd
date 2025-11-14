{ config, pkgs, lib, nixos-hardware, ... }:

{
  # Import the apple-t2 hardware module from nixos-hardware
  # This provides kernel patches, drivers, and configuration for T2 Macs
  imports = [
    nixos-hardware.nixosModules.apple-t2
  ];

  # T2 binary cache for pre-built packages
  # Significantly speeds up builds by using community cache
  nix.settings = {
    substituters = [
      "https://t2linux.cachix.org"
    ];
    trusted-public-keys = [
      "t2linux.cachix.org-1:P1TzTMk1US9G4Q7+8NpfnzYz3LU6iYY3D8L1u9mD6P8="
    ];
  };

  # T2-specific system packages
  environment.systemPackages = with pkgs; [
    # Tool to convert Apple disk images to standard formats
    dmg2img

    # Firmware extraction script for T2 devices
    # Users run this to extract firmware from macOS
    (pkgs.writeShellScriptBin "get-apple-firmware" ''
      # Firmware extraction script for T2 Linux
      # Based on: https://wiki.t2linux.org/guides/wifi/

      echo "=== Apple T2 Firmware Extraction Tool ==="
      echo ""
      echo "This script helps extract firmware from macOS for use in Linux."
      echo "You need a macOS partition or recovery image to extract firmware."
      echo ""
      echo "For detailed instructions, visit:"
      echo "https://wiki.t2linux.org/guides/wifi/"
      echo ""
      echo "Common firmware locations on macOS:"
      echo "  WiFi/Bluetooth: /usr/share/firmware/wifi/"
      echo "  Audio: /System/Library/Extensions/"
      echo ""
      echo "After extraction, copy firmware to /lib/firmware/ in NixOS"
    '')
  ];

  # Platform constraint: T2 Macs are x86_64 only
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
