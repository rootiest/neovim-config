--[[
  ┌────────────────────────────────────────────────────────────────┐
  │                        Rootiest Neovim                         │
  └────────────────────────────────────────────────────────────────┘
--]]

-- Copyright (C) 2026 Rootiest
-- SPDX-License-Identifier: AGPL-3.0-or-later

-- Trigger bootstrap (runtime path, etc.)
require("bootstrap")

-- Initialize global registry
_G.Config = {
	plugins = {},
	called = {},
}

-- Load core modules
require("lazyload") -- Plugin lazy-loading module
require("options") -- Configuration options
require("plugins") -- Plugin specifications and setup
require("keymaps") -- Key mappings

-- Source machine-local and secret overrides (silently ignored if absent)
local user_dots = vim.fn.expand("~/.config/.user-dots/nvim/")
for _, file in ipairs({ "secrets.lua", "local.lua" }) do
	local path = user_dots .. file
	if vim.fn.filereadable(path) == 1 then
		dofile(path)
	end
end
