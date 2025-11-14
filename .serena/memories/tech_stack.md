# Tech Stack

## Core Technologies
- **Nix**: Functional package manager and build system
- **NixOS**: Linux distribution built on Nix
- **Nix Flakes**: Experimental feature for reproducible, composable configurations

## Framework & Libraries
- **flake-parts**: Modular flake organization framework (eliminates duplication)
- **nixvim**: Declarative Neovim configuration via Nix
- **nixpkgs**: Main Nix package repository (nixos-unstable channel)

## Development Environment
- **System**: Darwin (macOS) - **Cannot build ISOs natively** (requires Linux)
- **Language**: Nix (functional, declarative configuration language)
- **Version Control**: Git
- **CI/CD**: GitHub Actions with QEMU emulation for cross-architecture builds

## Key Dependencies (from flake.nix)
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nixvim.url = "github:nix-community/nixvim";
  flake-parts.url = "github:hercules-ci/flake-parts";
  nixos-hardware.url = "github:NixOS/nixos-hardware";  # For T2 Mac support
}
```

## Editor Stack
- **Helix**: Modern terminal editor with LSP support
- **Neovim**: Extensible vim-based editor configured via nixvim
- **LSP**: nil (Nix Language Server) for both editors
- **Formatting**: nixpkgs-fmt for automatic Nix code formatting
- **Syntax Highlighting**: Treesitter for Nix language

## T2 MacBook Pro Binary Caches
- **t2linux.cachix.org**: Primary T2 Linux community cache
- **cache.soopy.moe**: Additional T2 Linux community cache
- **Configuration Pattern**: Uses three-line pattern in hardware/t2.nix
  - `extra-trusted-substituters`: Automatic for CI/CD and trusted users
  - `extra-substituters`: Fallback for non-trusted users
  - `extra-trusted-public-keys`: Cryptographic package verification
- **Purpose**: Provides pre-built T2-specific kernel modules and drivers

## T2-Specific Packages
- **python3**: Required by firmware extraction script for parsing firmware files
- **dmg2img**: Converts macOS disk images to standard formats
- **get-apple-firmware**: Comprehensive firmware extraction tool from t2linux/wiki
  - Source: https://github.com/t2linux/wiki (commit 360156db)
  - Extracts WiFi/Bluetooth firmware from macOS for Linux use
  - Supports multiple methods: EFI partition, macOS volume, recovery image
  - Uses embedded Python to parse and rename firmware files
  - Essential for T2 Mac WiFi/Bluetooth functionality on Linux