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