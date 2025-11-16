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
