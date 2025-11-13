{ config, pkgs, lib, ... }:

{
  # Install Neovim editor
  environment.systemPackages = with pkgs; [
    neovim
  ];

  # Default Neovim configuration (extensible)
  # To customize, you can add configurations here or use programs.neovim
  #
  # Example for future plugin/theme additions:
  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = false;  # Set to true to make it the default editor
  #   viAlias = true;
  #   vimAlias = true;
  #
  #   plugins = with pkgs.vimPlugins; [
  #     # Example plugins:
  #     # vim-nix
  #     # nvim-treesitter
  #     # telescope-nvim
  #   ];
  #
  #   extraConfig = ''
  #     " Basic settings
  #     set number
  #     set relativenumber
  #     syntax on
  #
  #     " Colorscheme (after installing theme plugin)
  #     " colorscheme gruvbox
  #   '';
  # };
  #
  # For themes, you can:
  # 1. Add theme plugins to the plugins list above
  # 2. Configure via extraConfig
  # 3. Or use external configuration files via environment.etc
  #
  # See: https://nixos.wiki/wiki/Neovim
}
