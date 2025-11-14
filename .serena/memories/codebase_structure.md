# Codebase Structure

## Overview

This is a **flake-parts-based** NixOS project that builds minimal installation ISOs for multiple architectures. The T2 ISO extends the upstream [t2linux/nixos-t2-iso](https://github.com/t2linux/nixos-t2-iso) project.

## Directory Layout

```
custom-minimal-cd/
├── flake.nix                    # Main flake entry point (uses flake-parts)
├── flake.lock                   # Dependency lock file (auto-generated)
├── configuration.nix            # Main system configuration
├── flake-parts/                 # Modular flake components
│   ├── iso.nix                 # Standard ISO builder logic with perSystem
│   └── t2-iso.nix              # T2 ISO (extends t2linux/nixos-t2-iso)
├── editors/                     # Editor-specific configurations
│   ├── helix.nix               # Helix editor setup
│   └── neovim.nix              # Neovim with nixvim configuration
├── .github/                     # GitHub-specific files
│   └── workflows/
│       └── build-iso.yml       # CI/CD pipeline for ISO builds
├── README.md                    # User documentation
├── CLAUDE.md                    # Claude Code assistant instructions
├── .gitignore                   # Git exclusions
└── renovate.json               # Renovate dependency updates config
```

## File Purposes

### Core Nix Files

**flake.nix**
- Entry point for the Nix flake
- Defines inputs (nixpkgs, nixvim, flake-parts, t2-iso)
- t2-iso input uses `inputs.nixpkgs.follows = "nixpkgs"` for version alignment
- Specifies supported systems: `x86_64-linux`, `aarch64-linux` (plus Darwin for dev tools)
- Imports flake-parts modules
- **Key Concept**: Uses flake-parts.lib.mkFlake for modular organization

**flake.lock**
- Auto-generated lock file pinning exact dependency versions
- Should be tracked in git for reproducibility
- Updated with `nix flake update`

**configuration.nix**
- Main system configuration imported by ISO modules
- Contains:
  - Editor imports (helix.nix, neovim.nix)
  - Experimental features (flakes, nix-command)
  - Root user password configuration
  - SSH settings
  - Networking (DHCP)
  - System packages
  - ISO-specific settings (filename, bootability)

### Flake-Parts Modules

**flake-parts/iso.nix**
- Contains `perSystem` function that generates outputs for each architecture
- Defines `mkIso` helper function that:
  - Takes system as input
  - Combines base NixOS minimal installation ISO module
  - Adds nixvim for Neovim configuration
  - Includes custom configuration.nix
  - Returns ISO package
- Creates `packages.<system>.iso` outputs automatically

**flake-parts/t2-iso.nix**
- T2 MacBook Pro ISO builder (extends t2linux/nixos-t2-iso)
- Only creates output for x86_64-linux (T2 Macs are Intel-based)
- **Upstream Integration**:
  - Imports base T2 ISO modules from t2linux (installation-cd-minimal, channel, apple-t2)
  - Inherits T2 binary caches (t2linux.cachix.org)
  - Includes firmware extraction tools from upstream
- **Our Additions**:
  - Custom editor configurations (Helix, Neovim with nixvim)
  - Custom system packages from configuration.nix
  - Unique filename override (`nixos-minimal-x86_64-t2-custom.iso`)
- Creates `packages.x86_64-linux.iso-t2` output

### Editor Configurations

**editors/helix.nix**
- Helix editor configuration module
- Uses `environment.etc` for TOML configuration files
- Includes nil LSP for Nix language support
- Configures themes, keybindings, editor behavior

**editors/neovim.nix**
- Neovim configuration using nixvim framework
- Declarative plugin management
- LSP configuration (nil for Nix)
- Treesitter syntax highlighting
- Colorscheme (Gruvbox)
- Custom keybindings (Space as leader)

### CI/CD

**.github/workflows/build-iso.yml**
- GitHub Actions workflow with dual job strategy
- **Job 1: build-standard** (x86_64, aarch64 in parallel)
  - Fast builds using pre-built kernels (2-5 minutes)
  - Uses QEMU for ARM64 emulation on x86_64 runners
  - No space cleanup needed
- **Job 2: build-t2** (separate dedicated job)
  - T2 kernel compilation requires ~90 minutes
  - Uses GC_DONT_GC=1 to prevent garbage collection during build
  - Maximizes build space before compilation
  - Uses --accept-flake-config flag
  - No QEMU (T2 is x86_64 only)
- Steps (per job):
  1. Checkout code
  2. Set up QEMU (standard job only)
  3. Install Nix with flakes
  4. Set up Nix cache
  5. Build ISO for each architecture
  6. Validate ISO (size check, existence)
  7. Upload to GitHub Actions artifacts (90-day retention)
  8. Upload to GitHub Releases (for tagged versions)

## Key Architectural Patterns

### Flake-Parts Modular Design
- **Problem**: Traditional flakes have duplication across systems
- **Solution**: flake-parts' `perSystem` automatically creates outputs for each system
- **Benefit**: Write ISO builder once, get packages for all architectures

### Module Composition
- **Pattern**: Import editor configs as separate modules
- **Location**: `imports = [ ./editors/helix.nix ./editors/neovim.nix ]`
- **Benefit**: Clean separation of concerns, easy to add/remove editors

### Override Strategy
- **Base Module**: Imports NixOS minimal installation ISO module
- **Customization**: Uses `lib.mkForce` to override defaults (e.g., root password)
- **Extension**: Adds packages and configuration on top of base

### T2 ISO Extension Strategy
- **Upstream Base**: Uses t2linux/nixos-t2-iso for T2 hardware support
- **Our Layer**: Adds custom editor configurations and packages
- **Clean Separation**: Hardware support from upstream, customizations from us
- **Benefit**: Upstream handles T2 kernel updates, we maintain only customizations

### Multi-Architecture Support
- **System List**: `systems = [ \"x86_64-linux\" \"aarch64-linux\" ]`
- **Auto-Detection**: `pkgs.stdenv.hostPlatform.system` in ISO filename
- **Build Constraint**: Requires Linux (cannot build on Darwin/macOS natively)

## Data Flow

### Standard ISO Build Process
1. User runs: `nix build .#packages.<arch>.iso`
2. Flake-parts processes `perSystem` for requested architecture
3. `mkIso` function called with system parameter
4. Combines: base ISO + nixvim + configuration.nix
5. Outputs: `result/iso/nixos-minimal-<arch>-custom.iso`

### T2 ISO Build Process
1. User runs: `nix build .#packages.x86_64-linux.iso-t2`
2. T2 ISO module extends t2linux/nixos-t2-iso base
3. Adds custom editor modules and configuration
4. Overrides filename for unique derivation
5. Outputs: `result/iso/nixos-minimal-x86_64-t2-custom.iso`

### CI/CD Flow
1. Push to main or create tag
2. GitHub Actions starts workflow with two jobs:
   - **build-standard**: Parallel matrix jobs for x86_64 and aarch64
   - **build-t2**: Separate dedicated job with GC protection
3. Each job: checkout → setup → build → validate → upload
4. T2 job gets full runner resources without competition
5. Artifacts available from Actions tab (90-day retention)
6. Releases created automatically for tags (permanent storage)

## Important Implementation Details

### Password Configuration
- Uses `users.users.root.password = \"installer\"`
- **Not** `initialHashedPassword` (for convenience)
- `lib.mkForce null` overrides base ISO's empty hash

### Flakes Always Enabled
- Set globally in `nix.settings.experimental-features`
- Users can run flake commands immediately after booting ISO

### ISO Filename Generation
- Dynamic: `nixos-minimal-${pkgs.stdenv.hostPlatform.system}-custom.iso`
- Automatically includes correct architecture in filename
- T2 ISO uses explicit override: `nixos-minimal-x86_64-t2-custom.iso`
- Example outputs: `nixos-minimal-x86_64-linux-custom.iso`, `nixos-minimal-aarch64-linux-custom.iso`

### T2 Hardware Support
- Provided by upstream t2linux/nixos-t2-iso
- Includes apple-t2 module, binary caches, firmware tools
- We only add custom editors and packages on top
