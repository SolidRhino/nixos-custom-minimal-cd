# Suggested Commands

## Development Workflow

### Building ISOs

**⚠️ IMPORTANT**: NixOS ISOs can **only** be built on Linux systems. Since this is a Darwin (macOS) system, use GitHub Actions for building.

```bash
# Check flake structure
nix flake show

# Update dependencies
nix flake update

# Format Nix files (nixpkgs-fmt configured)
nix fmt

# Evaluate configuration (quick validation without building)
nix eval .#nixosConfigurations.x86_64-linux.config.system.name
```

### GitHub Actions (Recommended for macOS)

```bash
# Push changes to trigger automatic build
git add .
git commit -m "Description of changes"
git push origin main

# Create a release (builds + publishes ISOs permanently)
git tag v1.0.0
git push origin v1.0.0

# Manual trigger via GitHub Actions UI:
# Go to: https://github.com/<user>/<repo>/actions
# Click "Build NixOS ISO" → "Run workflow"
```

### Git Commands

```bash
# Check status and current branch
git status
git branch

# Create feature branch for changes
git checkout -b feature/description

# View recent commits
git log --oneline -10

# View changes
git diff
```

### Project Structure Exploration

```bash
# List directory structure
ls -la
tree -L 2  # if tree is installed

# View flake inputs and outputs
nix flake metadata

# Check if flake is valid
nix flake check  # may not work on Darwin for ISO builds
```

## Testing ISOs (After GitHub Actions Build)

### Download from GitHub

1. Go to Actions tab in GitHub repository
2. Click on successful workflow run
3. Download artifacts (ISO files)
   - `nixos-minimal-x86_64-custom.iso` (Intel/AMD 64-bit)
   - `nixos-minimal-aarch64-custom.iso` (ARM64)

### Test with VM (macOS)

```bash
# Using UTM (recommended for M4 MacBooks)
# 1. Download UTM from https://mac.getutm.app/
# 2. Create new VM
# 3. Select ISO as boot media
# 4. Configure 2GB+ RAM
# 5. Boot and test

# Using QEMU (if installed)
qemu-system-x86_64 -m 2G -cdrom nixos-minimal-x86_64-custom.iso -boot d
qemu-system-aarch64 -M virt -cpu cortex-a72 -m 2G -cdrom nixos-minimal-aarch64-custom.iso -boot d
```

## Utility Commands (Darwin/macOS)

```bash
# File operations
ls -la          # list files with details
find . -name "*.nix"  # find Nix files
cat filename    # view file contents
grep "pattern" filename  # search in file

# Process management
ps aux          # list processes
top             # monitor system

# Network
ping host       # test connectivity
curl url        # fetch URL
ssh user@host   # SSH connection

# Disk usage
df -h           # disk space
du -sh *        # directory sizes
```

## Documentation

```bash
# View README
cat README.md

# View Claude instructions
cat CLAUDE.md

# List all Nix files
find . -name "*.nix" -type f
```