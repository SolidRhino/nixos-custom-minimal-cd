{ config, pkgs, lib, ... }:

{
  # Install Helix editor with LSP tooling
  environment.systemPackages = with pkgs; [
    helix
    nil           # Nix LSP server
    nixpkgs-fmt   # Nix formatter
  ];

  # Configure Helix language server for Nix
  environment.etc."helix/languages.toml".text = ''
    [[language]]
    name = "nix"
    language-servers = ["nil"]
    formatter = { command = "nixpkgs-fmt" }
    auto-format = true

    [language-server.nil]
    command = "nil"
  '';

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
