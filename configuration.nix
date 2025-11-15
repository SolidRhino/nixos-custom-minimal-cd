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

  # Install essential tools
  environment.systemPackages = with pkgs; [
    git

    # Modern CLI tools for enhanced developer experience
    ripgrep  # Fast grep replacement
    fd       # Fast find replacement
    bat      # Cat with syntax highlighting
    eza      # Modern ls replacement
    jq       # JSON processor
    yq-go    # YAML processor
    nmap     # Network exploration
    tmux     # Terminal multiplexer
    ncdu     # Disk usage analyzer
    btop     # Modern system monitor

    # All standard minimal ISO tools are included via the base module
  ];

  # ISO-specific settings
  image.fileName = lib.mkForce "nixos-minimal-${pkgs.stdenv.hostPlatform.system}-custom.iso";

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };
}
