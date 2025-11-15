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
