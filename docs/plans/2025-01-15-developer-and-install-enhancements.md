# Developer Optimized and Installation Focused Enhancements

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add modern CLI tools and installation helper scripts to enhance the NixOS minimal installation ISO for developers and installation workflows.

**Architecture:** Create modular Nix configuration files (motd.nix, shell-config.nix, scripts/quick-install.nix) that integrate with the existing flake-parts structure. Enhance editor configurations and update documentation to clarify base ISO inheritance.

**Tech Stack:** Nix, NixOS modules, Bash scripting, flake-parts

---

## Task 1: Create MOTD Module

**Files:**
- Create: `motd.nix`

**Step 1: Create MOTD module file**

Create `motd.nix` in project root:

```nix
{ config, lib, ... }:
{
  users.motd = ''
    ════════════════════════════════════════════════════════════
      NixOS Minimal Installation ISO (Custom Enhanced)
    ════════════════════════════════════════════════════════════
      Login: root / installer

      📝 Editors Available:
         • helix (hx)     - Modern modal editor with LSP
         • neovim (nvim)  - Configured with nixvim + Nix LSP
         • vim, nano      - Standard editors

      🌐 Network: NetworkManager enabled (nmtui for WiFi)
      🔐 SSH: Enabled on port 22
      📦 Flakes: Enabled (nix build, nix develop ready)

      💻 Modern CLI Tools:
         • ripgrep (rg)   - Fast search
         • fd             - Fast find
         • bat            - Better cat
         • eza            - Better ls
         • jq, yq         - JSON/YAML parsing

      Quick Start:
        sudo nmtui                 # Configure WiFi
        sudo fdisk -l              # List disks
        nixos-quick-start          # Installation helper
        nixos-install --help       # Installation guide
    ════════════════════════════════════════════════════════════
  '';
}
```

**Step 2: Verify file syntax**

Run: `nix eval --impure --expr 'import ./motd.nix { config = {}; lib = (import <nixpkgs> {}).lib; }'`

Expected: No syntax errors

**Step 3: Commit**

```bash
git add motd.nix
git commit -m "feat: add MOTD showing custom ISO features"
```

---

## Task 2: Create Shell Configuration Module

**Files:**
- Create: `shell-config.nix`

**Step 1: Create shell configuration module**

Create `shell-config.nix` in project root:

```nix
{ config, pkgs, lib, ... }:
{
  # Enhanced bash configuration
  programs.bash = {
    enableCompletion = true;

    shellAliases = {
      # Modern replacements
      ll = "eza -alh --group-directories-first";
      la = "eza -A";
      ls = "eza";
      cat = "bat --style=plain";

      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline -10";
      ga = "git add";
      gc = "git commit";

      # Network helpers
      myip = "ip -br addr show";
      ports = "ss -tuln";
      netinfo = "ip addr show && echo && ip route show";

      # Disk helpers
      df = "df -h";
      du = "du -h";
      diskinfo = "lsblk -f";

      # Nix shortcuts
      nxs = "nix search nixpkgs";
      nxr = "nix run nixpkgs#";
      nxd = "nix develop";
      nxb = "nix build";

      # Installation helpers
      partitions = "lsblk -f";
      mounts = "findmnt";
    };

    # Helpful prompt showing current directory
    promptInit = ''
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    '';
  };
}
```

**Step 2: Verify file syntax**

Run: `nix eval --impure --expr 'import ./shell-config.nix { config = {}; pkgs = (import <nixpkgs> {}); lib = (import <nixpkgs> {}).lib; }'`

Expected: No syntax errors

**Step 3: Commit**

```bash
git add shell-config.nix
git commit -m "feat: add shell configuration with modern CLI aliases"
```

---

## Task 3: Create Quick Install Helper Script

**Files:**
- Create: `scripts/quick-install.nix`

**Step 1: Create scripts directory**

Run: `mkdir -p scripts`

**Step 2: Create quick-install helper module**

Create `scripts/quick-install.nix`:

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nixos-quick-start" ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Colors for better readability
      GREEN='\033[0;32m'
      BLUE='\033[0;34m'
      YELLOW='\033[1;33m'
      NC='\033[0m' # No Color

      echo -e "''${GREEN}╔═══════════════════════════════════════════════════╗''${NC}"
      echo -e "''${GREEN}║  NixOS Quick Installation Helper                  ║''${NC}"
      echo -e "''${GREEN}╚═══════════════════════════════════════════════════╝''${NC}"
      echo ""

      echo -e "''${BLUE}📋 Step-by-Step Installation Guide:''${NC}"
      echo ""

      echo -e "''${YELLOW}1. Network Setup''${NC}"
      echo "   WiFi:     nmtui"
      echo "   Wired:    Should auto-configure via DHCP"
      echo "   Test:     ping -c 3 nixos.org"
      echo ""

      echo -e "''${YELLOW}2. Disk Preparation''${NC}"
      echo "   List:     lsblk -f"
      echo "   Partition: cfdisk /dev/sdX"
      echo "   Format:   mkfs.ext4 -L nixos /dev/sdX1"
      echo "             mkswap -L swap /dev/sdX2"
      echo ""

      echo -e "''${YELLOW}3. Mount Filesystems''${NC}"
      echo "   Root:     mount /dev/disk/by-label/nixos /mnt"
      echo "   Boot:     mkdir -p /mnt/boot"
      echo "             mount /dev/sdX1 /mnt/boot  # if UEFI"
      echo "   Swap:     swapon /dev/sdX2"
      echo ""

      echo -e "''${YELLOW}4. Generate Configuration''${NC}"
      echo "   Generate: nixos-generate-config --root /mnt"
      echo "   Edit:     nvim /mnt/etc/nixos/configuration.nix"
      echo "             # or: hx /mnt/etc/nixos/configuration.nix"
      echo ""

      echo -e "''${YELLOW}5. Install''${NC}"
      echo "   Install:  nixos-install"
      echo "   Reboot:   reboot"
      echo ""

      echo -e "''${BLUE}📝 Available Editors:''${NC}"
      echo "   • helix (hx)   - Modern modal editor with LSP"
      echo "   • neovim (nvim) - Configured with Nix LSP"
      echo "   • nano         - Beginner-friendly"
      echo "   • vim          - Classic"
      echo ""

      echo -e "''${BLUE}🔧 Useful Commands:''${NC}"
      echo "   diskinfo  - Show disk partitions and filesystems"
      echo "   netinfo   - Show network configuration"
      echo "   myip      - Show IP addresses"
      echo "   ll        - List files (modern ls with eza)"
      echo ""

      echo -e "''${GREEN}💡 Tip: Use 'man nixos-install' for detailed installation docs''${NC}"
      echo ""
    '')

    (pkgs.writeShellScriptBin "show-disk-layout" ''
      #!/usr/bin/env bash
      echo "=== Disk Layout ==="
      lsblk -f
      echo ""
      echo "=== Mount Points ==="
      findmnt
    '')

    (pkgs.writeShellScriptBin "show-network-info" ''
      #!/usr/bin/env bash
      echo "=== Network Interfaces ==="
      ip -br addr show
      echo ""
      echo "=== Default Routes ==="
      ip route show
      echo ""
      echo "=== DNS Configuration ==="
      cat /etc/resolv.conf
    '')
  ];
}
```

**Step 3: Verify file syntax**

Run: `nix eval --impure --expr 'import ./scripts/quick-install.nix { pkgs = (import <nixpkgs> {}); }'`

Expected: No syntax errors

**Step 4: Commit**

```bash
git add scripts/quick-install.nix
git commit -m "feat: add installation helper scripts"
```

---

## Task 4: Enhance Helix Configuration

**Files:**
- Modify: `editors/helix.nix`

**Step 1: Read current Helix configuration**

Run: `cat editors/helix.nix`

**Step 2: Enhance Helix configuration**

Update `editors/helix.nix` to match the enhanced configuration:

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.helix ];

  # Helix configuration
  environment.etc."helix/config.toml".text = ''
    theme = "catppuccin_mocha"

    [editor]
    line-number = "relative"
    mouse = true
    cursorline = true
    auto-save = false
    completion-trigger-len = 2
    bufferline = "multiple"
    color-modes = true

    [editor.statusline]
    left = ["mode", "spinner", "file-name", "file-modification-indicator"]
    right = ["diagnostics", "selections", "position", "file-encoding"]

    [editor.cursor-shape]
    insert = "bar"
    normal = "block"
    select = "underline"

    [editor.file-picker]
    hidden = false

    [editor.lsp]
    display-messages = true
    display-inlay-hints = true

    [editor.indent-guides]
    render = true
    character = "│"
  '';

  # Helix languages configuration
  environment.etc."helix/languages.toml".text = ''
    [[language]]
    name = "nix"
    language-servers = ["nil"]
    auto-format = true
    formatter = { command = "nixpkgs-fmt" }

    [language-server.nil]
    command = "nil"
  '';

  # Include nil LSP and formatter
  environment.systemPackages = with pkgs; [
    helix
    nil
    nixpkgs-fmt
  ];
}
```

**Step 3: Verify changes**

Run: `nix eval --impure --expr 'import ./editors/helix.nix { config = {}; pkgs = (import <nixpkgs> {}); }'`

Expected: No syntax errors

**Step 4: Commit**

```bash
git add editors/helix.nix
git commit -m "feat: enhance Helix configuration with Catppuccin Mocha theme"
```

---

## Task 5: Update configuration.nix with Modern Tools

**Files:**
- Modify: `configuration.nix`

**Step 1: Read current configuration**

Run: `cat configuration.nix`

**Step 2: Update configuration.nix**

Replace the imports and systemPackages sections in `configuration.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./editors/helix.nix
    ./editors/neovim.nix
    ./motd.nix
    ./shell-config.nix
    ./scripts/quick-install.nix
  ];

  # Enable flakes and nix-command experimental features system-wide
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set root password to "installer" (password is better for ephemeral ISO)
  users.users.root = {
    password = "installer";
    initialHashedPassword = lib.mkForce null;  # Override base ISO's empty hash
  };

  # Enable SSH with password authentication
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # Enable DHCP networking
  networking.useDHCP = lib.mkDefault true;

  # Install modern CLI tools (Developer Optimized)
  environment.systemPackages = with pkgs; [
    # Version control
    git

    # Modern CLI replacements
    ripgrep    # Better grep (rg)
    fd         # Better find
    bat        # Better cat with syntax highlighting
    eza        # Better ls with colors and git integration

    # Data processing
    jq         # JSON processor
    yq-go      # YAML processor

    # Network tools (beyond base ISO)
    nmap       # Network scanning

    # Terminal multiplexer
    tmux       # Session management

    # Disk usage
    ncdu       # Interactive disk usage analyzer

    # Performance monitoring (beyond base htop)
    btop       # Modern system monitor

    # All standard minimal ISO tools are included via the base module
  ];

  # ISO-specific settings
  image.fileName = lib.mkForce "nixos-minimal-${pkgs.stdenv.hostPlatform.system}-custom.iso";

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };
}
```

**Step 3: Verify changes**

Run: `nix eval --impure --expr 'import ./configuration.nix { config = {}; pkgs = (import <nixpkgs> {}); lib = (import <nixpkgs> {}).lib; }'`

Expected: No syntax errors

**Step 4: Commit**

```bash
git add configuration.nix
git commit -m "feat: add modern CLI tools and import new modules"
```

---

## Task 6: Update README Documentation

**Files:**
- Modify: `README.md`

**Step 1: Read current README**

Run: `cat README.md | head -30`

**Step 2: Add inheritance section after Features**

Add this new section after the "## Features" section in `README.md` (around line 16):

```markdown
## What's Included

### Base NixOS Minimal Installation ISO

This ISO inherits **all standard tools** from the NixOS minimal installation CD, including:

- **Disk Utilities**: fdisk, parted, gdisk, gptfdisk, cfdisk
- **Filesystems**: Support for ext4, btrfs, xfs, NTFS, FAT32, and more
- **Network**: NetworkManager with WiFi support (`nmtui` command for easy WiFi setup)
- **Hardware Tools**: lshw, pciutils, usbutils, dmidecode
- **Recovery Tools**: testdisk, ddrescue
- **Standard Editors**: nano, vim
- **Terminal**: screen (terminal multiplexer)
- **Compression**: gzip, bzip2, xz, and more
- **Network Tools**: curl, wget, rsync, inetutils
- **And much more**: All standard Linux utilities and NixOS installation tools

### Custom Enhancements

On top of the base ISO, this custom version adds:

#### 🎨 Modern Editors
- **Helix** (`hx`) - Modern modal editor with built-in LSP support and Catppuccin Mocha theme
- **Neovim** (`nvim`) - Configured via nixvim with Nix LSP, Treesitter, Gruvbox theme

#### 💻 Developer-Optimized CLI Tools
- **ripgrep** (`rg`) - Fast recursive search tool
- **fd** - Fast and user-friendly alternative to find
- **bat** - Cat clone with syntax highlighting
- **eza** - Modern ls replacement with colors and git integration
- **jq** / **yq** - JSON and YAML processors
- **tmux** - Terminal multiplexer for session management
- **ncdu** - Interactive disk usage analyzer
- **btop** - Modern resource monitor

#### 🚀 Installation Helpers
- **nixos-quick-start** - Interactive installation guide
- **show-disk-layout** - Quick disk and partition overview
- **show-network-info** - Network configuration details
- Shell aliases for common tasks (ll, gs, myip, etc.)

#### ⚙️ Quality of Life
- **Flakes Enabled** - Use nix build/develop/run immediately
- **SSH Ready** - Password authentication enabled (root/installer)
- **Enhanced Shell** - Bash with completion and helpful aliases
- **MOTD** - Welcome message showing available tools and quick start guide
```

**Step 3: Update Quick Start section**

Replace the "Boot the ISO" section (around line 29) with:

```markdown
### Boot the ISO

1. Write the ISO to a USB drive or boot in a VM
2. Boot from the ISO
3. Log in as `root` with password `installer`
4. You'll see a welcome message (MOTD) showing available tools
5. Run `nixos-quick-start` for an interactive installation guide
6. Network should auto-configure via DHCP (or run `nmtui` for WiFi)
7. SSH is available for remote access
```

**Step 4: Add modern tools usage examples**

Add new section before "## Customization" (around line 124):

```markdown
## Using Modern CLI Tools

The ISO includes modern alternatives to standard Unix tools:

### Search and Navigation
```bash
# Fast file search (better than find)
fd config.nix
fd "\.nix$" /etc

# Fast text search (better than grep)
rg "imports" --type nix
rg -i "nixos" configuration.nix

# Better file listing
ll              # Alias for: eza -alh --group-directories-first
eza --tree      # Tree view
eza --git       # Show git status
```

### File Viewing
```bash
# Syntax-highlighted file viewing
bat configuration.nix
bat --style=plain file.txt  # No line numbers

# Interactive disk usage
ncdu /
```

### Data Processing
```bash
# JSON processing
nix flake metadata --json | jq '.locks.nodes'

# YAML processing
yq eval '.services' config.yaml
```

### System Monitoring
```bash
# Modern system monitor
btop

# Network information helpers
myip        # Show IP addresses
netinfo     # Full network configuration
ports       # Show listening ports
```

### Installation Helpers
```bash
# Interactive installation guide
nixos-quick-start

# Quick disk overview
show-disk-layout

# Network status
show-network-info
```
```

**Step 5: Verify markdown syntax**

Run: `cat README.md | grep -E "^##" | head -20`

Expected: Should show proper heading hierarchy

**Step 6: Commit**

```bash
git add README.md
git commit -m "docs: document base ISO inheritance and modern CLI tools"
```

---

## Task 7: Update CLAUDE.md Documentation

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Add new modules to Project Overview**

Add to the "Core Architecture" section in `CLAUDE.md` (after line 12):

```markdown
- **motd.nix**: Message of the day showing available features
- **shell-config.nix**: Bash configuration with modern aliases
- **scripts/quick-install.nix**: Installation helper scripts
```

**Step 2: Update Common Commands section**

Add new section after "Development Workflow" in `CLAUDE.md` (around line 35):

```markdown
### Testing ISO Features

```bash
# After building/downloading ISO, boot in VM and verify:
- MOTD displays on login
- Run: nixos-quick-start
- Run: show-disk-layout
- Run: show-network-info
- Test aliases: ll, gs, myip
- Test modern tools: rg, fd, bat, eza
```
```

**Step 3: Update Configuration Patterns**

Add to the "Configuration Patterns" section:

```markdown
### Installation Helpers

Helper scripts are defined in `scripts/quick-install.nix` using `pkgs.writeShellScriptBin`:

```nix
(pkgs.writeShellScriptBin "script-name" ''
  #!/usr/bin/env bash
  # Script content here
'')
```

These scripts become available system-wide after ISO boots.
```

**Step 4: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with new modules and features"
```

---

## Task 8: Update Serena Memory Files

**Files:**
- Modify: `.serena/memories/project_overview.md`
- Modify: `.serena/memories/codebase_structure.md`

**Step 1: Update project overview memory**

Update `.serena/memories/project_overview.md` to include new features:

Add to "Key Features" section:

```markdown
- **Modern CLI Tools**: ripgrep, fd, bat, eza, jq, yq, tmux, ncdu, btop
- **Installation Helpers**: Quick-start guide, disk/network info scripts
- **Enhanced Shell**: Bash with completion and helpful aliases
- **MOTD**: Welcome message showing available tools
```

**Step 2: Update codebase structure memory**

Update `.serena/memories/codebase_structure.md` to include new files:

Add to the directory layout:

```markdown
├── motd.nix                     # Message of the day configuration
├── shell-config.nix             # Bash configuration with aliases
├── scripts/                     # Helper scripts
│   └── quick-install.nix       # Installation helper scripts
```

Add to "Core Nix Files" section:

```markdown
**motd.nix**
- Message of the day (MOTD) configuration
- Shows available editors, tools, and quick start guide
- Displayed on login to root account

**shell-config.nix**
- Bash shell configuration
- Modern CLI tool aliases (ll, cat -> bat, etc.)
- Git shortcuts (gs, gd, gl)
- Network helpers (myip, netinfo)
- Nix shortcuts (nxs, nxb, nxd)

**scripts/quick-install.nix**
- Installation helper scripts using writeShellScriptBin
- nixos-quick-start: Interactive installation guide
- show-disk-layout: Disk and partition overview
- show-network-info: Network configuration details
```

**Step 3: Commit**

```bash
git add .serena/memories/project_overview.md .serena/memories/codebase_structure.md
git commit -m "docs: update Serena memories with new features"
```

---

## Task 9: Build and Test ISO

**Files:**
- Test: Build process and ISO functionality

**Step 1: Validate flake configuration**

Run: `nix flake check`

Expected: No errors (or skip if on Darwin)

**Step 2: Format all Nix files**

Run: `nix fmt`

Expected: Files formatted according to nixpkgs-fmt

**Step 3: Show flake structure**

Run: `nix flake show`

Expected: Display packages.x86_64-linux.iso and packages.aarch64-linux.iso

**Step 4: Commit formatting changes**

```bash
git add -A
git commit -m "style: format Nix files with nixpkgs-fmt"
```

**Step 5: Push to GitHub for CI build**

```bash
git push origin main
```

**Step 6: Monitor GitHub Actions**

- Go to: https://github.com/<user>/<repo>/actions
- Wait for build to complete
- Download artifacts for testing

**Step 7: Test ISO in VM (after download)**

Manual testing checklist:
- [ ] Boot ISO in VM (UTM, QEMU, or VirtualBox)
- [ ] Verify MOTD displays with custom features
- [ ] Run `nixos-quick-start` - verify output
- [ ] Run `show-disk-layout` - verify disk info
- [ ] Run `show-network-info` - verify network info
- [ ] Test aliases: `ll`, `gs`, `myip`
- [ ] Test modern tools: `rg --version`, `fd --version`, `bat --version`, `eza --version`
- [ ] Test editors: `hx` and `nvim` work with Nix LSP
- [ ] Verify SSH access from another machine

---

## Task 10: Create Summary Documentation

**Files:**
- Create: `docs/ENHANCEMENTS.md`

**Step 1: Create enhancements documentation**

Create `docs/ENHANCEMENTS.md`:

```markdown
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
```

**Step 2: Commit**

```bash
git add docs/ENHANCEMENTS.md
git commit -m "docs: add comprehensive enhancements documentation"
```

**Step 3: Final push**

```bash
git push origin main
```

---

## Completion Checklist

After completing all tasks:

- [ ] All new modules created (motd.nix, shell-config.nix, scripts/quick-install.nix)
- [ ] Helix configuration enhanced
- [ ] configuration.nix updated with modern CLI tools
- [ ] README.md documents base ISO inheritance
- [ ] CLAUDE.md updated with new modules
- [ ] Serena memories updated
- [ ] ISO builds successfully in GitHub Actions
- [ ] ISO tested in VM with all features working
- [ ] Documentation created (ENHANCEMENTS.md)
- [ ] All commits follow conventional commit format
- [ ] Changes pushed to GitHub

## Verification Commands

```bash
# Verify all new files exist
ls -la motd.nix shell-config.nix
ls -la scripts/quick-install.nix

# Verify imports in configuration.nix
grep -A 6 "imports" configuration.nix

# Check flake validity
nix flake show

# View recent commits
git log --oneline -10

# Check GitHub Actions status
gh run list --limit 1
```

---

**Plan complete!** All tasks are sequenced with exact file paths, code snippets, commands, and expected outputs.
