{ config, pkgs, ... }:

{
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
