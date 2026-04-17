--[[
  ┌────────────────────────────────────────────────────────────────┐
  │                            Plugins                             │
  └────────────────────────────────────────────────────────────────┘
--]]

-- Catppuccin.nvim
-- Eagerly load the colorscheme plugin.
vim.pack.add { { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } }

-- Catppuccin Config
Config.plugins.catppuccin = {
  flavour = "mocha",
}
vim.cmd.colorscheme "catppuccin"

-- Snacks.nvim
-- Eagerly load snacks for dashboard and performance features.
vim.pack.add { { src = "https://github.com/folke/snacks.nvim", name = "snacks" } }

-- Snacks Config
-- Store opts in the registry first.
Config.plugins.snacks = {
  bigfile = { enabled = true },
  dashboard = { 
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    },
  },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  picker = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
}

-- Setup Snacks with the registered opts.
require("snacks").setup(Config.plugins.snacks)

-- Persistence.nvim
-- Simple session management.
vim.pack.add { { src = "https://github.com/folke/persistence.nvim", name = "persistence" } }

-- Persistence Config
Config.plugins.persistence = {
  dir = vim.fn.stdpath("state") .. "/sessions/",
  need = 1,
  branch = true,
}
require("persistence").setup(Config.plugins.persistence)

-- Lazy-loaded Plugins
local lazyload = require("lazyload")

lazyload.on_vim_enter(function()
  -- Gitsigns.nvim
  vim.pack.add { { src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" } }
  require("gitsigns").setup({
    numhl = true, -- Enable line number highlighting
  })

  -- Grug-far.nvim
  vim.pack.add { { src = "https://github.com/MagicDuck/grug-far.nvim", name = "grug-far" } }
  require("grug-far").setup()

  -- Flash.nvim
  vim.pack.add { { src = "https://github.com/folke/flash.nvim", name = "flash" } }
  require("flash").setup()

  -- Which-key.nvim
  vim.pack.add { { src = "https://github.com/folke/which-key.nvim", name = "which-key" } }
  require("which-key").setup()

  -- Mini.ai
  vim.pack.add { { src = "https://github.com/echasnovski/mini.ai", name = "mini.ai" } }
  
  Config.plugins.mini_ai = {
    custom_textobjects = {
      g = function()
        local n_lines = vim.api.nvim_buf_line_count(0)
        return {
          from = { line = 1, col = 1 },
          to = { line = n_lines, col = math.max(vim.fn.getline(n_lines):len(), 1) },
        }
      end,
    },
  }
  require("mini.ai").setup(Config.plugins.mini_ai)

  -- Icons
  vim.pack.add { { src = "https://github.com/nvim-tree/nvim-web-devicons", name = "nvim-web-devicons" } }

  -- Lualine
  vim.pack.add { { src = "https://github.com/nvim-lualine/lualine.nvim", name = "lualine" } }
  require("lualine").setup({
    options = {
      theme = "auto",
      globalstatus = true,
    },
    sections = {
      lualine_b = { "branch", "diff", "diagnostics" },
    }
  })

  -- Noice dependencies
  vim.pack.add { { src = "https://github.com/MunifTanjim/nui.nvim", name = "nui" } }

  -- Noice.nvim
  vim.pack.add { { src = "https://github.com/folke/noice.nvim", name = "noice" } }
  require("noice").setup({
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.set_autocmds"] = true,
        ["vim.ui.codelens.display_inline"] = true,
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
  })
end)
