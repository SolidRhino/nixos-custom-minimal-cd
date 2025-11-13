# Custom Minimal NixOS Installation ISO

A flake-based minimal NixOS installation ISO with enhanced tooling for quick installations, repairs, and multi-machine deployments.

## Features

- **Editors**: Helix and Neovim (both pre-installed)
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

- Nix with flakes enabled
- Sufficient disk space (~5-10 GB)

### Building on M4 MacBook (or other aarch64 systems)

You can build the **aarch64** ISO locally:

```bash
# Build aarch64 ISO
nix build .#nixosConfigurations.aarch64-iso.config.system.build.isoImage

# ISO will be in: result/iso/nixos-minimal-aarch64-custom.iso
```

**Note**: Building x86_64 ISOs on M4 MacBook is not supported natively. Use GitHub Actions for x86_64 builds.

### Building on x86_64 Linux

You can build both architectures:

```bash
# Build x86_64 ISO
nix build .#nixosConfigurations.x86_64-iso.config.system.build.isoImage

# Build aarch64 ISO (requires binfmt emulation or remote builder)
nix build .#nixosConfigurations.aarch64-iso.config.system.build.isoImage
```

## GitHub Actions CI/CD

### Automatic Builds

Builds are automatically triggered on:

1. **Push to main/master**: Every commit triggers a build
2. **Git tags** (e.g., `v1.0.0`): Creates a GitHub Release with ISOs attached
3. **Manual dispatch**: Trigger via GitHub Actions UI
4. **Daily schedule**: Automatic build at 00:00 UTC

### Build Strategy

- Both architectures build in **parallel** for speed
- **Nix caching** via GitHub Actions reduces build times
- **Validation tests** ensure ISO integrity before upload
- **Artifacts** available for all builds (90-day retention)
- **Releases** created automatically for tagged versions

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

#### Neovim

Edit `editors/neovim.nix`:

```nix
programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    vim-nix
    nvim-treesitter
    gruvbox-nvim
  ];

  extraConfig = ''
    set number
    set relativenumber
    colorscheme gruvbox
  '';
};
```

See [NixOS Neovim Wiki](https://nixos.wiki/wiki/Neovim) for more options.

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

### Testing aarch64 ISO Locally (M4 MacBook)

1. Build the ISO:
   ```bash
   nix build .#nixosConfigurations.aarch64-iso.config.system.build.isoImage
   ```

2. Test in a VM using UTM or QEMU:
   ```bash
   # Example with QEMU (if available)
   qemu-system-aarch64 \
     -M virt \
     -cpu cortex-a72 \
     -m 2G \
     -cdrom result/iso/*.iso \
     -boot d
   ```

### Testing x86_64 ISO

Use GitHub Actions to build, then test in:
- VirtualBox
- VMware
- QEMU
- Real hardware

## Project Structure

```
custom-minimal-cd/
├── .github/
│   └── workflows/
│       └── build-iso.yml       # GitHub Actions workflow
├── editors/
│   ├── helix.nix              # Helix editor configuration
│   └── neovim.nix             # Neovim editor configuration
├── flake.nix                  # Main flake entry point
├── flake.lock                 # Flake dependencies lock file
├── configuration.nix          # System configuration
└── README.md                  # This file
```

## Workflow

### Typical Development Workflow

1. Make changes to configuration files
2. Test aarch64 build locally (if on M4):
   ```bash
   nix build .#nixosConfigurations.aarch64-iso.config.system.build.isoImage
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

**Issue**: `error: cannot build on 'x86_64-linux' platform`

**Solution**: You're on a non-compatible architecture (e.g., M4 Mac). Either:
- Build only the compatible architecture (aarch64 on M4)
- Use GitHub Actions for cross-platform builds

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
