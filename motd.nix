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
