{ config, pkgs, lib, ... }:

{
  imports = [
    ./editors/helix.nix
    ./editors/neovim.nix
  ];

  # Enable flakes and nix-command experimental features system-wide
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set root password to "installer"
  users.users.root.initialPassword = "installer";

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
    # All standard minimal ISO tools are included via the base module
  ];

  # ISO-specific settings
  image.fileName = lib.mkForce "nixos-minimal-${pkgs.stdenv.hostPlatform.system}-custom.iso";

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };
}
