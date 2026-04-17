--[[
  ┌────────────────────────────────────────────────────────────────┐
  │                        Rootiest Neovim                         │
  └────────────────────────────────────────────────────────────────┘
--]]

-- Copyright (C) 2026 rootiest
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
