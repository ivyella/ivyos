{ config, pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      signcolumn = "yes";
      termguicolors = true;

      mouse = "a";
      clipboard = "unnamedplus";

      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;

      wrap = false;
      scrolloff = 8;
      sidescrolloff = 8;

      splitright = true;
      splitbelow = true;

      updatetime = 250;
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = true;
      };
    };

    plugins = {
      lualine.enable = true;
      web-devicons.enable = true;

      bufferline = {
        enable = true;
        settings.options = {
          mode = "buffers";
          separator_style = "thin";
          show_buffer_close_icons = true;
          show_close_icon = false;
          always_show_bufferline = true;

          close_command = {__raw = "function(bufnr) CloseBuf(bufnr) end";};
          
          offsets = [
            {
              filetype = "neo-tree";
              text = "File Explorer";
              text_align = "center";
              separator = true;
            }
          ];
        };
      };

      which-key = {
        enable = true;
        settings.spec = [
          { __unkeyed-1 = "<leader>f"; group = "Find"; }
          { __unkeyed-1 = "<leader>b"; group = "Buffers"; }
          { __unkeyed-1 = "<leader>l"; group = "LSP"; }
          { __unkeyed-1 = "<leader>u"; group = "UI"; }
          { __unkeyed-1 = "<leader>q"; group = "Quit"; }
        ];
      };

      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = false;
          filtered_items = {
            visible = true;  
            hide_dotfiles = false;  
            hide_gitignored = false;  
            hide_hidden = false;  
            hide_by_pattern = [];
          };
        };
      };

      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fr" = "oldfiles";
          "<leader>fh" = "help_tags";
        };
      };

      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };

      gitsigns.enable = true;
      comment.enable = true;
      nvim-autopairs.enable = true;

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
            settings.check.command = "clippy";
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.mapping = {
          "<Tab>" = { __raw = "cmp.mapping.select_next_item()"; };
          "<S-Tab>" = { __raw = "cmp.mapping.select_prev_item()"; };
          "<CR>" = { __raw = "cmp.mapping.confirm({ select = true })"; };
          "<C-Space>" = { __raw = "cmp.mapping.complete()"; };
        };
      };

      luasnip.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
    };

    keymaps = [
      { mode = "n"; key = "<leader>w"; action = ":w<CR>"; options.desc = "Save"; }
      { mode = "n"; key = "<leader>H"; action = ":Neotree filesystem toggle_hidden<CR>"; options.desc = "Toggle hidden files"; }

      { mode = "n"; key = "<leader>qq"; action = "<cmd>close<CR>"; options.desc = "Close window"; }
      { mode = "n"; key = "<leader>qa"; action = "<cmd>qa<CR>"; options.desc = "Quit all"; }
      { mode = "n"; key = "<leader>q!"; action = "<cmd>qa!<CR>"; options.desc = "Force quit"; }

      { mode = "n"; key = "<leader>x"; action = "<cmd>lua CloseBuf()<CR>"; options.desc = "Close buffer"; }

      { mode = "n"; key = "<leader>>"; action = ":bnext<CR>"; options.desc = "Next buffer"; }
      { mode = "n"; key = "<leader><"; action = ":bprevious<CR>"; options.desc = "Prev buffer"; }

      { mode = "n"; key = "<leader>e"; action = ":Neotree toggle<CR>"; options.desc = "Toggle explorer"; }
      { mode = "n"; key = "<leader>E"; action = ":Neotree focus<CR>"; options.desc = "Focus explorer"; }

      { mode = "n"; key = "<leader>h"; action = "<C-w>h"; options.desc = "Win left"; }
      { mode = "n"; key = "<leader>j"; action = "<C-w>j"; options.desc = "Win down"; }
      { mode = "n"; key = "<leader>k"; action = "<C-w>k"; options.desc = "Win up"; }
      { mode = "n"; key = "<leader>l"; action = "<C-w>l"; options.desc = "Win right"; }

      { mode = "n"; key = "<leader>a"; action = "ggVG"; options.desc = "Select all"; }

      { mode = "n"; key = "<leader>c"; action = "\"+y"; options.desc = "Copy"; }
      { mode = "v"; key = "<leader>c"; action = "\"+y"; options.desc = "Copy"; }
      { mode = "n"; key = "<leader>d"; action = "\"+d"; options.desc = "Cut"; }
      { mode = "v"; key = "<leader>d"; action = "\"+d"; options.desc = "Cut"; }
      { mode = "n"; key = "<leader>v"; action = "\"+p"; options.desc = "Paste"; }

      { mode = "n"; key = "<leader>z"; action = "u"; options.desc = "Undo"; }
      { mode = "n"; key = "<leader>Z"; action = "<C-r>"; options.desc = "Redo"; }

      { mode = "n"; key = "<leader>/"; action = "/"; options.desc = "Search"; }
      { mode = "n"; key = "<leader>F"; action = ":Telescope<CR>"; options.desc = "Search menu"; }

      { mode = "n"; key = "gd"; action = "<cmd>lua vim.lsp.buf.definition()<CR>"; options.desc = "Definition"; }
      { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<CR>"; options.desc = "Rename"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; options.desc = "Actions"; }

      { mode = "n"; key = "<leader>uh"; action = ":nohlsearch<CR>"; options.desc = "Clear highlight"; }

      { mode = "v"; key = "<"; action = "<gv"; options.desc = "Indent left"; }
      { mode = "v"; key = ">"; action = ">gv"; options.desc = "Indent right"; }
      { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move down"; }
      { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move up"; }

      { mode = "n"; key = "<C-s>"; action = ":w<CR>"; options.desc = "Save"; }
      { mode = "i"; key = "<C-s>"; action = "<Esc>:w<CR>a"; options.desc = "Save"; }
    ];

    extraConfigLua = ''
      function CloseBuf(bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        local buffers = vim.fn.getbufinfo({ buflisted = 1 })
        if #buffers > 1 then
          vim.cmd("bdelete " .. bufnr)
        else
          vim.cmd("enew")
          vim.cmd("bdelete " .. bufnr)
        end
      end

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.cmd("Neotree show")
        end,
      })
    '';
  };
}
