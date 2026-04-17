--[[
  ┌────────────────────────────────────────────────────────────────┐
  │                        Rootiest Neovim                         │
  └────────────────────────────────────────────────────────────────┘
--]]

-- Set leader keys before loading any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Initialize global registry
_G.Config = {
  plugins = {},
  called = {},
}

-- Load core modules
require('lazyload')
require('options')
require('plugins')
require('keymaps')
