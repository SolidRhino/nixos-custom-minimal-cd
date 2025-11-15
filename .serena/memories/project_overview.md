# Project Overview

## Purpose
Custom minimal NixOS installation ISO with enhanced tooling for quick installations, repairs, and multi-machine deployments.

## Key Features
- **Multi-Architecture Support**: x86_64-linux and aarch64-linux (ARM64)
- **Pre-configured Editors**: Helix and Neovim with nixvim (LSP, Treesitter, syntax highlighting)
- **Development Tools**: Git, Nix LSP (nil), auto-formatting
- **SSH Access**: Enabled with password authentication (root password: `installer`)
- **Networking**: DHCP auto-configuration
- **Flakes**: Experimental features permanently enabled system-wide
- **Automated CI/CD**: GitHub Actions builds both architectures in parallel

## Output
- ISO images suitable for USB boot or VM usage
- Filenames: `nixos-minimal-x86_64-custom.iso` and `nixos-minimal-aarch64-custom.iso`
- Size: ~500-800 MB per architecture

## Use Cases
- Quick NixOS installations
- System repairs and recovery
- Multi-machine deployments
- Testing NixOS configurations
- Educational/learning environments