# Darwin (macOS) Specific Constraints

## Critical Limitation

**NixOS ISOs CANNOT be built natively on macOS (Darwin).**

This is a fundamental architectural constraint:
- NixOS ISOs require Linux-specific kernel modules and boot infrastructure
- ISO generation depends on Linux filesystems and boot loaders
- Cross-compilation from Darwin to NixOS ISOs is not supported

## Development System

Current system: **Darwin** (macOS, including M4 MacBooks)

### What You CAN Do on Darwin
✅ Edit Nix configuration files
✅ Run `nix flake show` to inspect outputs
✅ Run `nix flake update` to update dependencies
✅ Run `nix fmt` to format Nix code (nixpkgs-fmt configured)
✅ Use git for version control
✅ Test Nix expressions with `nix eval`
✅ Push to GitHub to trigger CI/CD builds

### What You CANNOT Do on Darwin
❌ Build ISOs with `nix build .#iso`
❌ Test ISO builds locally
❌ Run `nix flake check` (may fail due to ISO-specific checks)
❌ Build NixOS configurations directly
❌ Test system packages that are Linux-specific

## Recommended Workflow for Darwin Users

### Primary Development Method: GitHub Actions

1. **Make changes** to configuration files locally on macOS
2. **Commit and push** to GitHub repository
3. **GitHub Actions** automatically builds both ISOs (x86_64, aarch64)
4. **Download ISOs** from GitHub Actions artifacts or releases
5. **Test ISOs** in a VM (UTM recommended for M4 Macs)

### Alternative Methods

#### Option 1: Linux VM on macOS
- Use UTM (recommended for Apple Silicon)
- Use VirtualBox or Parallels
- Run Linux guest and build ISOs inside VM
- Requires setting up Nix inside Linux VM

#### Option 2: Remote Builder
- Configure a remote Linux machine as Nix builder
- Requires advanced Nix configuration
- See: https://nixos.wiki/wiki/Distributed_build

#### Option 3: Docker with NixOS
- Not recommended due to complexity
- Limited support for ISO building in containers

## Testing Strategy on Darwin

Since you can't build ISOs locally:

### 1. Configuration Validation
```bash
# Syntax check (may fail for ISO-specific parts)
nix flake show

# Evaluate specific attributes
nix eval .#packages.x86_64-linux --json
```

### 2. VM Testing (After GitHub Build)
- Download ISO from GitHub Actions artifacts
- Use UTM (https://mac.getutm.app/) for virtualization
- Test boot, SSH, and functionality
- Recommended VM settings:
  - 2GB+ RAM
  - 20GB+ disk
  - UEFI boot
  - Network: bridged or NAT

### 3. Real Hardware Testing
- Write ISO to USB drive using `dd` or Balena Etcher
- Boot on actual hardware
- Most thorough testing method

## Darwin-Specific Commands

### Useful macOS Utilities
```bash
# System information
uname -a              # Shows Darwin kernel version
sw_vers               # Shows macOS version

# Package management (if Homebrew installed)
brew list             # List installed packages
brew search <pkg>     # Search for packages

# Nix on Darwin
nix --version         # Check Nix version
nix-info -m           # Show Nix system info

# File operations
open .                # Open current directory in Finder
pbcopy < file         # Copy file contents to clipboard
pbpaste > file        # Paste clipboard to file
```

## Summary

When working on this project from Darwin:
1. **Edit locally**, commit, push to GitHub
2. **Let GitHub Actions build** ISOs for both targets (x86_64, aarch64)
3. **Download and test** built ISOs in VM or hardware
4. **Never attempt** `nix build .#iso` locally (will fail)