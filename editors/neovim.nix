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
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = false;
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
          "<leader>d" = "open_float";
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

    # Telescope - Fuzzy finder
    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Find files";
        };
        "<leader>fg" = {
          action = "live_grep";
          options.desc = "Live grep";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Find buffers";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Help tags";
        };
      };
    };

    # Neo-tree - File explorer (LazyVim style)
    plugins.neo-tree = {
      enable = true;
      enableGitStatus = true;
      enableDiagnostics = true;
      closeIfLastWindow = true;
      window = {
        width = 30;
        position = "left";
      };
    };

    # Noice - Modern UI for messages, cmdline and popupmenu
    plugins.noice = {
      enable = true;
      settings = {
        lsp = {
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = false;
          lsp_doc_border = false;
        };
      };
    };

    # Dressing - Better vim.ui
    plugins.dressing = {
      enable = true;
    };

    # Bufferline - Buffer tabs at top
    plugins.bufferline = {
      enable = true;
      settings = {
        options = {
          diagnostics = "nvim_lsp";
          always_show_bufferline = true;
          separator_style = "slant";
          themable = true;
        };
      };
    };

    # Alpha - Startup dashboard
    plugins.alpha = {
      enable = true;
      layout = [
        {
          type = "padding";
          val = 2;
        }
        {
          type = "text";
          val = [
            "███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗"
            "████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝"
            "██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗"
            "██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║"
            "██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║"
            "╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
          ];
          opts = {
            position = "center";
            hl = "Type";
          };
        }
        {
          type = "padding";
          val = 2;
        }
        {
          type = "group";
          val = [
            {
              type = "button";
              val = "  Find file";
              on_press = { __raw = "function() require('telescope.builtin').find_files() end"; };
              opts = {
                shortcut = "SPC ff";
                keymap = ["n" "<leader>ff" ":Telescope find_files<CR>" { noremap = true; silent = true; }];
                position = "center";
                cursor = 3;
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "button";
              val = "  New file";
              on_press = { __raw = "function() vim.cmd[[ene]] end"; };
              opts = {
                shortcut = "SPC n";
                keymap = ["n" "<leader>fn" ":ene<CR>" { noremap = true; silent = true; }];
                position = "center";
                cursor = 3;
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "button";
              val = "  Quit";
              on_press = { __raw = "function() vim.cmd[[qa]] end"; };
              opts = {
                shortcut = "q";
                keymap = ["n" "q" ":qa<CR>" { noremap = true; silent = true; }];
                position = "center";
                cursor = 3;
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
          ];
        }
      ];
    };

    # Aerial - Code outline and navigation
    plugins.aerial = {
      enable = true;
      settings = {
        layout = {
          default_direction = "prefer_right";
          placement = "edge";
        };
        attach_mode = "global";
        backends = ["lsp" "treesitter"];
      };
    };

    # Indent-blankline - Indentation guides
    plugins.indent-blankline = {
      enable = true;
      settings = {
        scope = {
          enabled = true;
          show_start = true;
          show_end = true;
        };
      };
    };

    # Trouble - Pretty diagnostics list
    plugins.trouble = {
      enable = true;
    };

    # Fidget - LSP progress notifications
    plugins.fidget = {
      enable = true;
    };

    # Mini modules - Small useful plugins
    plugins.mini = {
      enable = true;
      modules = {
        pairs = { };  # Auto pairs
        surround = { };  # Surround text objects
        comment = { };  # Better commenting
      };
    };

    # Lualine - Status line
    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          theme = "catppuccin";
          icons_enabled = true;
        };
      };
    };

    # Which-key - Keymap hints
    plugins.which-key = {
      enable = true;
    };

    # Basic keymaps
    keymaps = [
      # File explorer toggle (neo-tree)
      {
        mode = "n";
        key = "<leader>e";
        action = ":Neotree toggle<CR>";
        options = {
          desc = "Toggle file explorer";
          silent = true;
        };
      }

      # Code outline toggle (aerial)
      {
        mode = "n";
        key = "<leader>a";
        action = ":AerialToggle<CR>";
        options = {
          desc = "Toggle code outline";
          silent = true;
        };
      }

      # Trouble diagnostics
      {
        mode = "n";
        key = "<leader>xx";
        action = ":Trouble diagnostics toggle<CR>";
        options = {
          desc = "Toggle diagnostics";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>xq";
        action = ":Trouble quickfix toggle<CR>";
        options = {
          desc = "Toggle quickfix";
          silent = true;
        };
      }

      # Buffer navigation
      {
        mode = "n";
        key = "<S-h>";
        action = ":BufferLineCyclePrev<CR>";
        options = {
          desc = "Previous buffer";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<S-l>";
        action = ":BufferLineCycleNext<CR>";
        options = {
          desc = "Next buffer";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = ":bdelete<CR>";
        options = {
          desc = "Delete buffer";
          silent = true;
        };
      }

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
