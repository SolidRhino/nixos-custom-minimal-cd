# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A flake-based NixOS minimal installation ISO with enhanced tooling for quick installations, repairs, and multi-machine deployments. The project uses **flake-parts** for modular organization and supports x86_64, aarch64, and x86_64-t2 (extends t2linux/nixos-t2-iso) architectures with automated CI/CD builds.

## Core Architecture

### Flake-Parts Modular Design

This project uses [flake-parts](https://flake.parts/) to eliminate duplication and organize the flake structure:

- **flake.nix**: Entry point that imports flake-parts modules and t2linux/nixos-t2-iso
- **flake-parts/iso.nix**: Contains the `perSystem` configuration and ISO builder logic for standard ISOs
- **flake-parts/t2-iso.nix**: T2 MacBook Pro ISO builder (extends t2linux/nixos-t2-iso)
- **configuration.nix**: System configuration imported by ISO modules
- **editors/**: Modular editor configurations (helix.nix, neovim.nix)

**Key Pattern**: The `mkIso` helper function in `flake-parts/iso.nix` creates ISO images for each system by combining:
1. Base minimal installation ISO module from nixpkgs
2. nixvim module for declarative Neovim configuration
3. Custom configuration.nix with system settings

### Multi-Architecture Support

The flake defines `systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]` to support Intel/AMD, ARM architectures, and development on Darwin. The `perSystem` function in flake-parts automatically creates packages for each system:

- `packages.x86_64-linux.iso` - Intel/AMD ISO
- `packages.aarch64-linux.iso` - ARM ISO
- `packages.x86_64-linux.iso-t2` - T2 MacBook Pro ISO (x86_64 with T2 hardware support)
- `packages.<current-system>.iso` - Auto-detected architecture (when available)

**T2 Support**: The T2 ISO extends [t2linux/nixos-t2-iso](https://github.com/t2linux/nixos-t2-iso), adding:
- Custom editor configurations (Helix, Neovim with nixvim)
- All T2 hardware support from upstream (apple-t2 module, firmware tools, binary caches)
- Same system packages and configuration as standard ISOs

**Important**: Building cross-architecture ISOs requires appropriate builders or emulation. GitHub Actions handles this automatically.

## Common Commands

### Building ISOs

```bash
# Build ISO for current system architecture (auto-detected)
nix build .#iso

# Build ISO for specific architecture
nix build .#packages.x86_64-linux.iso
nix build .#packages.aarch64-linux.iso

# Build T2 MacBook Pro ISO (only on x86_64 Linux)
nix build .#packages.x86_64-linux.iso-t2

# Output locations:
# - Standard: result/iso/nixos-minimal-{arch}-custom.iso
# - T2: result/iso/nixos-minimal-x86_64-linux-custom.iso
```

### Development Workflow

```bash
# Check flake configuration
nix flake show

# Update flake dependencies
nix flake update

# Test configuration changes without full build
nix eval .#nixosConfigurations.x86_64-linux.config.system.name

# Format Nix files
nix fmt
```

### CI/CD Testing

The GitHub Actions workflow (`.github/workflows/build-iso.yml`) uses a dual job strategy:
- **build-standard**: x86_64 and aarch64 ISOs build in parallel (fast, 2-5 minutes)
- **build-t2**: T2 ISO builds separately with GC protection (~90 minutes for kernel compilation)

Trigger manually via:

```bash
# Push to trigger automatic build
git push origin main

# Create release (builds + publishes ISOs)
git tag v1.0.0
git push origin v1.0.0
```

## Configuration Patterns

### Adding System Packages

Edit `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  git
  # Add new packages here
];
```

### Editor Customization

**Helix** (`editors/helix.nix`):
- Uses `environment.etc` to configure via TOML
- Includes nil LSP for Nix

**Neovim** (`editors/neovim.nix`):
- Uses nixvim for declarative configuration
- LSP, Treesitter, and plugins configured via nixvim options
- Space key is configured as leader

### Modifying ISO Output

The ISO filename is controlled in `configuration.nix`:

```nix
image.fileName = lib.mkForce "nixos-minimal-${pkgs.stdenv.hostPlatform.system}-custom.iso";
```

The `pkgs.stdenv.hostPlatform.system` dynamically sets the architecture name in the output filename.

## Architecture-Specific Considerations

### Local Building Constraints

- **M4 MacBook (aarch64)**: Can only build aarch64 ISOs natively
- **x86_64 Linux**: Can build x86_64 ISOs natively, requires binfmt or remote builder for aarch64
- **Cross-compilation**: Not supported for NixOS ISOs - use GitHub Actions for non-native architectures

### GitHub Actions Strategy

**Dual Job Approach:**
- **build-standard job**: Uses matrix strategy for x86_64 and aarch64 (parallel, fast)
- **build-t2 job**: Dedicated runner with GC_DONT_GC=1 to prevent garbage collection during 90-minute kernel build

**Infrastructure:**
- Employs DeterminateSystems nix-installer and magic-nix-cache for performance
- T2 job maximizes build space before kernel compilation
- Validates ISO size (must be >100MB) before upload
- Artifacts retained for 90 days, releases are permanent

## Important Implementation Details

### Password Authentication

The ISO uses password authentication (not SSH keys) for convenience:
- Root password: `installer`
- Set via `users.users.root.password` (not `initialHashedPassword`)
- `lib.mkForce null` overrides the base ISO's empty password hash

### Flakes Enabled Globally

Experimental features are enabled system-wide in `configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

This ensures users can run flake commands immediately after booting the ISO.

### Module Import Order

The order in `flake-parts/iso.nix` matters:
1. Base minimal installation ISO (provides foundation)
2. nixvim module (adds Neovim declarative configuration)
3. Custom configuration.nix (overrides and extends)

### T2 ISO Implementation

The T2 ISO extends the upstream [t2linux/nixos-t2-iso](https://github.com/t2linux/nixos-t2-iso) project:

1. **Base T2 ISO from t2linux** (includes apple-t2 module, firmware tools, binary caches)
2. **Custom editors** (nixvim, Helix, Neovim configurations)
3. **Custom configuration** (same system packages as standard ISOs)
4. **Unique filename override** (`nixos-minimal-x86_64-t2-custom.iso`)

**Architecture**: T2 MacBook Pros are x86_64 only (Intel-based, 2018-2020 models).

**Upstream Features** (provided by t2linux/nixos-t2-iso):
- Apple T2 hardware support (WiFi, audio, keyboard, TouchBar)
- Firmware extraction tools (`get-apple-firmware` command)
- T2 Linux community binary cache (t2linux.cachix.org)
- nixos-hardware apple-t2 module integration

**Our Additions**:
- Helix and Neovim (nixvim) editor configurations
- Custom system packages from configuration.nix

## Testing Approach

1. **Local build test**: `nix build .#iso` (for current architecture)
2. **CI validation**: Push to trigger GitHub Actions build
3. **ISO boot test**: Use VM (QEMU, VirtualBox, UTM) or physical hardware
4. **SSH test**: Boot ISO, verify network and SSH access with `installer` password

## Project Conventions

### Git Commit Messages

**IMPORTANT**: Never add Claude Code attribution to git commits.

The following lines must **NOT** be included in commit messages:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

This is explicitly forbidden per project policy.

**Commit Message Format**:
- Use conventional commits: `feat:`, `fix:`, `docs:`, `config:`, `ci:`
- Write descriptive, meaningful messages
- Include context and rationale for changes
- Keep first line under 72 characters

## Troubleshooting

### Build Errors

- **"cannot build on 'x86_64-linux' platform"**: You're on incompatible architecture (e.g., M4 Mac). Use GitHub Actions or build only your native architecture.
- **"experimental features not enabled"**: Ensure your system has flakes enabled in `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`

### Flake-Parts Understanding

If unfamiliar with flake-parts:
- Read the `flake-parts/` directory structure first
- Understand that `perSystem` creates outputs for each system in `systems = [...]`
- The `mkIso` function is called once per architecture automatically
- Traditional `nixosConfigurations` are not used; flake-parts generates packages instead
