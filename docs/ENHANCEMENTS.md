# ISO Enhancements Documentation

This document describes the custom enhancements added to the base NixOS minimal installation ISO.

## Architecture

This ISO uses a **layered approach**:

1. **Base Layer**: NixOS minimal installation ISO (`installation-cd-minimal.nix`)
   - Provides comprehensive disk, network, filesystem, and recovery tools
   - Includes standard editors (nano, vim) and utilities

2. **Enhancement Layer**: Custom modules that add modern tooling
   - `motd.nix`: Welcome message
   - `shell-config.nix`: Enhanced bash with aliases
   - `scripts/quick-install.nix`: Installation helpers
   - `editors/helix.nix`: Modern modal editor with LSP
   - `editors/neovim.nix`: Configured neovim via nixvim

## Developer-Optimized Tools (Option B)

### Modern CLI Replacements
- **ripgrep** → Better grep with smart defaults
- **fd** → Better find with simple syntax
- **bat** → Better cat with syntax highlighting
- **eza** → Better ls with colors and git integration

### Data Processing
- **jq** → JSON manipulation and querying
- **yq** → YAML manipulation and querying

### Workflow Tools
- **tmux** → Terminal multiplexer for session management
- **ncdu** → Interactive disk usage analyzer
- **btop** → Modern system resource monitor
- **nmap** → Network discovery and security auditing

### Shell Aliases

All modern tools are aliased for convenience:

```bash
ll    → eza -alh --group-directories-first
cat   → bat --style=plain
ls    → eza
gs    → git status
myip  → ip -br addr show
```

See `shell-config.nix` for complete list.

## Installation-Focused Features (Option C)

### Interactive Helpers

**nixos-quick-start**
- Step-by-step installation guide
- Network setup instructions
- Disk preparation steps
- Configuration generation
- Installation and reboot

**show-disk-layout**
- Display all disks and partitions
- Show filesystem types
- Display current mount points

**show-network-info**
- Show IP addresses
- Display default routes
- Show DNS configuration

### Enhanced MOTD

The welcome message displays:
- Available editors
- Modern CLI tools
- Network configuration status
- SSH information
- Quick start commands

### Shell Enhancements

- Tab completion enabled
- Helpful aliases for common tasks
- Color-coded prompt showing username, host, and path
- Git integration in file listings (eza)

## Usage Examples

### Quick Installation Workflow

```bash
# 1. Boot ISO, MOTD displays automatically
# 2. Run installation helper
nixos-quick-start

# 3. Configure WiFi (if needed)
nmtui

# 4. Check disk layout
show-disk-layout

# 5. Partition disk
cfdisk /dev/sda

# 6. Format and mount
mkfs.ext4 -L nixos /dev/sda1
mount /dev/disk/by-label/nixos /mnt

# 7. Generate config
nixos-generate-config --root /mnt

# 8. Edit with modern editor
nvim /mnt/etc/nixos/configuration.nix
# or: hx /mnt/etc/nixos/configuration.nix

# 9. Install
nixos-install

# 10. Reboot
reboot
```

### Developer Workflow

```bash
# Search for files
fd "configuration" /etc

# Search in files
rg "imports" --type nix

# View files with syntax highlighting
bat configuration.nix

# Better directory listing
ll

# JSON processing
nix flake metadata --json | jq '.locks'

# System monitoring
btop
```

## Testing

See `README.md` for VM testing instructions.

Quick verification checklist:
- [ ] MOTD displays on boot
- [ ] All helper scripts work
- [ ] Modern CLI tools available
- [ ] Aliases function correctly
- [ ] Editors have LSP support
- [ ] Network auto-configures
- [ ] SSH accessible

## Maintenance

When adding new tools or scripts:

1. Add to appropriate module file
2. Update `configuration.nix` imports if needed
3. Update MOTD in `motd.nix`
4. Document in `README.md`
5. Update Serena memories
6. Test in VM before release

## Future Enhancements

Potential additions:
- Additional language LSPs (Python, Rust, Go)
- More Treesitter grammars for syntax highlighting
- ZSH as alternative shell option
- Recovery-focused ISO variant
- Automated partitioning script
