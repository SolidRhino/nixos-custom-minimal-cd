{ config, pkgs, lib, ... }:

{
  # Configure Neovim using nixvim
  programs.nixvim = {
    enable = true;

    # Make it available as default editor
    defaultEditor = false;  # Set to true if you want nixvim as the default
    viAlias = true;
    vimAlias = true;

    # Color scheme
    colorschemes.gruvbox = {
      enable = true;
      settings = {
        contrast = "medium";
      };
    };

    # Basic editor options
    opts = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Indentation
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoindent = true;

      # Search
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;

      # UI
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;

      # Performance
      updatetime = 300;
      timeoutlen = 500;

      # Better editing
      wrap = false;
      scrolloff = 8;
      sidescrolloff = 8;
    };

    # Global settings
    globals = {
      mapleader = " ";  # Space as leader key
    };

    # Treesitter for syntax highlighting
    plugins.treesitter = {
      enable = true;
      nixGrammars = true;

      settings = {
        highlight.enable = true;
        indent.enable = true;

        # Only include Nix grammar for ISO size
        ensure_installed = [ "nix" ];
      };
    };

    # LSP configuration for Nix
    plugins.lsp = {
      enable = true;

      servers = {
        # nil: Lightweight Nix language server
        nil_ls = {
          enable = true;
          settings = {
            formatting.command = [ "nixpkgs-fmt" ];
          };
        };
      };

      keymaps = {
        diagnostic = {
          "<leader>e" = "open_float";
          "[d" = "goto_prev";
          "]d" = "goto_next";
        };

        lspBuf = {
          "gd" = "definition";
          "gr" = "references";
          "K" = "hover";
          "<leader>rn" = "rename";
          "<leader>ca" = "code_action";
          "<leader>f" = "format";
        };
      };
    };

    # Basic keymaps
    keymaps = [
      # Better window navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options = { desc = "Move to left window"; };
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options = { desc = "Move to bottom window"; };
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options = { desc = "Move to top window"; };
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options = { desc = "Move to right window"; };
      }

      # Clear search highlighting
      {
        mode = "n";
        key = "<leader>h";
        action = ":nohlsearch<CR>";
        options = {
          desc = "Clear search highlights";
          silent = true;
        };
      }

      # Better indenting in visual mode
      {
        mode = "v";
        key = "<";
        action = "<gv";
        options = { desc = "Indent left"; };
      }
      {
        mode = "v";
        key = ">";
        action = ">gv";
        options = { desc = "Indent right"; };
      }

      # Save file
      {
        mode = "n";
        key = "<leader>w";
        action = ":w<CR>";
        options = {
          desc = "Save file";
          silent = true;
        };
      }

      # Quit
      {
        mode = "n";
        key = "<leader>q";
        action = ":q<CR>";
        options = {
          desc = "Quit";
          silent = true;
        };
      }
    ];
  };

  # Install nixpkgs-fmt for Nix formatting (used by nil LSP)
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
  ];
}

# Extensibility Guide:
# ====================
#
# Add more language servers:
# --------------------------
# plugins.lsp.servers.pyright.enable = true;  # Python
# plugins.lsp.servers.rust-analyzer.enable = true;  # Rust
# plugins.lsp.servers.ts-ls.enable = true;  # TypeScript
#
# Add more treesitter grammars:
# -----------------------------
# plugins.treesitter.settings.ensure_installed = [ "nix" "python" "rust" "typescript" ];
#
# Add plugins:
# ------------
# plugins.telescope.enable = true;  # Fuzzy finder
# plugins.nvim-tree.enable = true;  # File explorer
# plugins.lualine.enable = true;  # Status line
# plugins.bufferline.enable = true;  # Buffer tabs
# plugins.which-key.enable = true;  # Keymap hints
#
# Change colorscheme:
# -------------------
# colorschemes.catppuccin.enable = true;
# colorschemes.tokyonight.enable = true;
# colorschemes.nord.enable = true;
#
# See nixvim options: https://nix-community.github.io/nixvim/
