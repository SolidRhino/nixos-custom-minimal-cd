{ config, pkgs, lib, ... }:

{
  # Install Helix editor
  environment.systemPackages = with pkgs; [
    helix
  ];

  # Default Helix configuration (extensible)
  # To customize, you can add configurations here or override via environment variables
  #
  # Example for future theme/plugin additions:
  # environment.etc."helix/config.toml".text = ''
  #   theme = "onedark"
  #
  #   [editor]
  #   line-number = "relative"
  #   mouse = true
  # '';
  #
  # Themes can be added by:
  # 1. Adding theme files to environment.etc."helix/themes/"
  # 2. Or using helix runtime directory configuration
  #
  # See: https://docs.helix-editor.com/configuration.html
}
