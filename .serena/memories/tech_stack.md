# Tech Stack

## Core Technologies
- **Nix**: Functional package manager and build system
- **NixOS**: Linux distribution built on Nix
- **Nix Flakes**: Experimental feature for reproducible, composable configurations

## Framework & Libraries
- **flake-parts**: Modular flake organization framework (eliminates duplication)
- **nixvim**: Declarative Neovim configuration via Nix
- **nixpkgs**: Main Nix package repository (nixos-unstable channel)
- **t2linux/nixos-t2-iso**: Upstream T2 MacBook Pro installer base

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
  t2-iso.url = "github:t2linux/nixos-t2-iso";  # T2 Mac installer base
}
```

## Editor Stack
- **Helix**: Modern terminal editor with LSP support
- **Neovim**: Extensible vim-based editor configured via nixvim
- **LSP**: nil (Nix Language Server) for both editors
- **Formatting**: nixpkgs-fmt for automatic Nix code formatting
- **Syntax Highlighting**: Treesitter for Nix language

## T2 MacBook Pro Support
The T2 ISO extends [t2linux/nixos-t2-iso](https://github.com/t2linux/nixos-t2-iso), which provides:

- **apple-t2 module**: Hardware-specific kernel modules and drivers
- **Binary Cache**: t2linux.cachix.org for pre-built T2 packages
- **Firmware Tools**: get-apple-firmware script for WiFi/Bluetooth firmware extraction
- **System Packages**: python3, dmg2img for firmware processing

Our customizations add:
- Custom editor configurations (Helix, Neovim with nixvim)
- Same system packages as standard ISOs
