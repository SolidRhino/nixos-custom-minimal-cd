# Custom Minimal NixOS Installation ISO

A flake-based minimal NixOS installation ISO with enhanced tooling for quick installations, repairs, and multi-machine deployments.

## Features

- **Editors**: Helix and Neovim with nixvim (both pre-installed)
- **LSP Support**: Nix language server (nil) with auto-formatting
- **Syntax Highlighting**: Treesitter for Nix with extensible grammar support
- **Version Control**: Git included
- **SSH Access**: Enabled with password authentication (password: `installer`)
- **Networking**: DHCP auto-configuration
- **Flakes**: Experimental features permanently enabled
- **Multi-Architecture**: Supports x86_64 and aarch64 (ARM64)
- **Automated Builds**: GitHub Actions CI/CD pipeline

## Quick Start

### Download Pre-Built ISOs

Pre-built ISOs are available from:
- **Latest Builds**: [GitHub Actions Artifacts](../../actions)
- **Tagged Releases**: [GitHub Releases](../../releases)

ISO filenames:
- `nixos-minimal-x86_64-custom.iso` (for Intel/AMD 64-bit)
- `nixos-minimal-aarch64-custom.iso` (for ARM 64-bit)

### Boot the ISO

1. Write the ISO to a USB drive or boot in a VM
2. Boot from the ISO
3. Log in as `root` with password `installer`
4. Network should auto-configure via DHCP
5. SSH is available for remote access

## Local Building

### Prerequisites

- **Linux system** (x86_64-linux or aarch64-linux)
- Nix with flakes enabled
- Sufficient disk space (~5-10 GB)

**Important**: NixOS ISOs can only be built on Linux systems. macOS users (including M4 MacBooks) should use GitHub Actions for building ISOs.

### Building on aarch64 Linux

If you're on an ARM64 Linux system:

```bash
# Build aarch64 ISO (auto-detects your architecture)
nix build .#iso

# Or use the explicit architecture path
nix build .#packages.aarch64-linux.iso

# ISO will be in: result/iso/nixos-minimal-aarch64-custom.iso
```

### Building on x86_64 Linux

On Intel/AMD Linux systems, you can build both architectures:

```bash
# Build x86_64 ISO (auto-detects your architecture)
nix build .#iso

# Or build specific architecture explicitly
nix build .#packages.x86_64-linux.iso
nix build .#packages.aarch64-linux.iso

# Note: Building aarch64 on x86_64 requires binfmt emulation or remote builder
```

### Building on macOS (M4 MacBook, etc.)

**NixOS ISOs cannot be built natively on macOS.** Use one of these alternatives:

1. **GitHub Actions** (Recommended): Push to GitHub and let CI/CD build both architectures
2. **Linux VM**: Use UTM, Parallels, or VirtualBox with a Linux guest
3. **Remote Builder**: Configure a remote Linux builder in your Nix configuration

## GitHub Actions CI/CD

### Automatic Builds

Builds are automatically triggered on:

1. **Push to main/master**: Every commit triggers a build
2. **Git tags** (e.g., `v1.0.0`): Creates a GitHub Release with ISOs attached
3. **Manual dispatch**: Trigger via GitHub Actions UI
4. **Daily schedule**: Automatic build at 00:00 UTC

### Build Strategy

**Parallel Build Approach:**
- x86_64 and aarch64 build in **parallel** for speed
- Use pre-built kernels from cache
- **QEMU emulation** enables aarch64 builds on x86_64 runners
- Fast builds: 2-5 minutes for x86_64, 20-45 minutes for aarch64

**Infrastructure:**
- **Nix caching** via GitHub Actions reduces build times
- **Validation tests** ensure ISO integrity before upload
- **Artifacts** available for all builds (90-day retention)
- **Releases** created automatically for tagged versions

**Build Times:**
- x86_64 builds: ~2-5 minutes (native, pre-built kernel)
- aarch64 builds: ~20-45 minutes (QEMU emulation overhead)

### Accessing Build Artifacts

#### From GitHub Actions
1. Go to [Actions tab](../../actions)
2. Click on a workflow run
3. Download artifacts at the bottom

#### From Releases
1. Go to [Releases](../../releases)
2. Download ISOs from release assets

## Customization

### Adding Editor Themes/Plugins

#### Helix

Edit `editors/helix.nix`:

```nix
environment.etc."helix/config.toml".text = ''
  theme = "onedark"

  [editor]
  line-number = "relative"
  mouse = true
'';
```

See [Helix documentation](https://docs.helix-editor.com/configuration.html) for more options.

#### Neovim (nixvim)

The ISO uses [nixvim](https://github.com/nix-community/nixvim) for declarative Neovim configuration with built-in LSP support for Nix.

**Current Features**:
- 🎨 Gruvbox colorscheme
- 🌳 Treesitter syntax highlighting (Nix)
- 🔧 LSP with nil (Nix language server)
- ⌨️ Sensible keybindings (Space as leader)
- 📝 Auto-formatting with nixpkgs-fmt

**Adding More Language Servers**:

Edit `editors/neovim.nix`:

```nix
plugins.lsp.servers = {
  nil_ls.enable = true;         # Nix (already enabled)
  pyright.enable = true;        # Python
  rust-analyzer.enable = true;  # Rust
  ts-ls.enable = true;          # TypeScript
};
```

**Adding More Treesitter Grammars**:

```nix
plugins.treesitter.settings.ensure_installed = [
  "nix"
  "python"
  "rust"
  "typescript"
];
```

**Adding Plugins**:

```nix
plugins.telescope.enable = true;    # Fuzzy finder
plugins.nvim-tree.enable = true;    # File explorer
plugins.lualine.enable = true;      # Status line
plugins.which-key.enable = true;    # Keymap hints
```

**Changing Colorscheme**:

```nix
# Disable gruvbox first
colorschemes.gruvbox.enable = false;

# Enable another theme
colorschemes.catppuccin.enable = true;
# or
colorschemes.tokyonight.enable = true;
# or
colorschemes.nord.enable = true;
```

**Key Bindings** (Space as leader):
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>h` - Clear search highlights
- `<leader>f` - Format code
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action
- `<leader>e` - Show diagnostics
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show hover info
- `[d` / `]d` - Previous/next diagnostic

See [nixvim documentation](https://nix-community.github.io/nixvim/) for all available options.

### Adding Additional Packages

Edit `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  git
  tmux          # Terminal multiplexer
  htop          # Process viewer
  curl          # HTTP client
  # Add more packages here
];
```

### Modifying SSH Configuration

Edit `configuration.nix`:

```nix
services.openssh = {
  enable = true;
  settings = {
    PermitRootLogin = "yes";
    PasswordAuthentication = true;
    # Add more SSH options here
  };
};
```

### Changing Root Password

Edit `configuration.nix`:

```nix
users.users.root.initialPassword = "your-password-here";
```

## Testing

### Testing ISOs

Once you have an ISO (built locally on Linux or downloaded from GitHub Actions):

**On Linux:**
- Use QEMU, VirtualBox, or VMware
- Write to USB and boot on real hardware

**On macOS:**
- Use UTM (recommended for M4 MacBooks)
- Use VirtualBox or Parallels
- Example with UTM: Create new VM, select ISO as boot media

**QEMU Examples:**

```bash
# Test x86_64 ISO
qemu-system-x86_64 \
  -m 2G \
  -cdrom nixos-minimal-x86_64-custom.iso \
  -boot d

# Test aarch64 ISO (on ARM Linux or with QEMU emulation)
qemu-system-aarch64 \
  -M virt \
  -cpu cortex-a72 \
  -m 2G \
  -cdrom nixos-minimal-aarch64-custom.iso \
  -boot d
```

**Real Hardware:**
- Write ISO to USB: `dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress`
- Boot from USB and test installation

## Project Structure

```
custom-minimal-cd/
├── .github/
│   └── workflows/
│       └── build-iso.yml           # GitHub Actions workflow
├── editors/
│   ├── helix.nix                  # Helix editor configuration
│   └── neovim.nix                 # Neovim editor configuration
├── flake-parts/
│   └── iso.nix                    # ISO configuration module
├── flake.nix                      # Main flake entry point (uses flake-parts)
├── flake.lock                     # Flake dependencies lock file
├── configuration.nix              # System configuration
└── README.md                      # This file
```

## Workflow

### Typical Development Workflow

1. Make changes to configuration files
2. Test build locally (uses current system architecture):
   ```bash
   nix build .#iso
   ```
3. Commit and push to GitHub
4. GitHub Actions builds both architectures
5. Download ISOs from Actions artifacts or Releases

### Creating a Release

1. Tag your commit:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. GitHub Actions automatically builds and creates a Release
3. ISOs are attached to the Release

## Technical Details

### System Configuration

- **Base**: NixOS minimal installation ISO
- **Init System**: systemd
- **Boot**: UEFI and USB bootable
- **Networking**: NetworkManager with DHCP
- **SSH**: OpenSSH server (port 22)
- **Flakes**: Enabled via `nix.settings.experimental-features`

### Build Outputs

- **x86_64 ISO**: `nixos-minimal-x86_64-custom.iso`
- **aarch64 ISO**: `nixos-minimal-aarch64-custom.iso`
- **Size**: ~500-800 MB (varies by architecture)

### CI/CD Pipeline

- **Runner**: Ubuntu latest (GitHub-hosted)
- **Nix Install**: DeterminateSystems nix-installer
- **Cache**: Magic Nix Cache for faster builds
- **Validation**: File existence, size checks
- **Artifacts**: 90-day retention
- **Releases**: Permanent storage for tagged versions

## Troubleshooting

### Build Fails Locally

**Issue**: `error: cannot build on 'x86_64-linux' platform` or `error: a 'x86_64-linux' with features {} is required`

**Cause**: NixOS ISOs can only be built on Linux systems. You may be:
- On macOS (including M4 MacBooks) - ISOs require Linux-specific features
- Missing required system features or architecture support

**Solution**:
- **macOS users**: Use GitHub Actions for building (recommended)
- **Linux users**: Ensure you're using the correct architecture path:
  - On x86_64: `nix build .#packages.x86_64-linux.iso`
  - On aarch64: `nix build .#packages.aarch64-linux.iso`
- **Cross-architecture builds**: Set up binfmt emulation or remote builder

### ISO Doesn't Boot

**Possible causes**:
- UEFI/BIOS compatibility issue
- Corrupted download
- Incorrect USB write method

**Solutions**:
- Verify ISO checksum
- Re-download ISO
- Use tools like `dd` (Linux/Mac) or Rufus (Windows) to write USB
- Check BIOS/UEFI boot settings

### SSH Connection Refused

**Possible causes**:
- Network not configured
- SSH service not started
- Firewall blocking

**Solutions**:
- Check IP address: `ip addr`
- Restart SSH: `systemctl restart sshd`
- Check SSH status: `systemctl status sshd`

### Can't Access GitHub Actions Artifacts

**Solution**: Ensure you're logged into GitHub and have access to the repository.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally (if possible)
5. Submit a pull request

## License

This project is provided as-is for educational and personal use.

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOS ISO Image](https://nixos.wiki/wiki/Creating_a_NixOS_live_CD)
- [Helix Editor](https://helix-editor.com/)
- [Neovim](https://neovim.io/)
