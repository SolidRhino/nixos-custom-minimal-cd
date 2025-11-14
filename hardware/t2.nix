{ config, pkgs, lib, nixos-hardware, ... }:

{
  # Import the apple-t2 hardware module from nixos-hardware
  # This provides kernel patches, drivers, and configuration for T2 Macs
  imports = [
    nixos-hardware.nixosModules.apple-t2
  ];

  # T2 binary caches for pre-built packages
  # Significantly speeds up builds by using community caches
  # Using three-line pattern for maximum compatibility:
  # - extra-trusted-substituters: Works automatically for trusted users (CI/CD)
  # - extra-substituters: Falls back for non-trusted users
  # - extra-trusted-public-keys: Cryptographic verification
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

  # T2-specific system packages
  environment.systemPackages = with pkgs; [
    # Python 3 - Required by firmware extraction script
    python3

    # Tool to convert Apple disk images to standard formats
    # Required by firmware script for processing macOS recovery images
    dmg2img

    # Firmware extraction script for T2 devices
    # Comprehensive tool that extracts WiFi/Bluetooth firmware from macOS
    # Uses python3 to parse and rename firmware files for Linux compatibility
    (pkgs.stdenvNoCC.mkDerivation {
      pname = "get-apple-firmware";
      version = "360156db52c013dbdac0ef9d6e2cebbca46b955b";

      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/t2linux/wiki/360156db52c013dbdac0ef9d6e2cebbca46b955b/docs/tools/firmware.sh";
        hash = "sha256-IL7omNdXROG402N2K9JfweretTnQujY67wKKC8JgxBo=";
      };

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/get-apple-firmware
        chmod +x $out/bin/get-apple-firmware
      '';

      meta = with lib; {
        description = "A script to get needed firmware for T2 Linux devices";
        license = licenses.mit;
        platforms = platforms.linux;
      };
    })
  ];

  # Platform constraint: T2 Macs are x86_64 only
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
