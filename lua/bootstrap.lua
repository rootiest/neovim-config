--          ╭─────────────────────────────────────────────────────────╮
--          │                        Bootstaps                        │
--          ╰─────────────────────────────────────────────────────────╯

---- Copyright (C) 2026 Rootiest
-- SPDX-License-Identifier: GPL-3.0-or-later

-- This file is sourced before anything else so it can be used to set up
-- the runtime path and other fundamental settings.

--  ─────────────── Manage root user permissions for Neovim ───────────────

-- Redirect data directories if running as root to avoid permission issues
if os.getenv("USER") == "root" or os.getenv("SUDO_USER") ~= nil then
	local root_data = "/root/.local/share/nvim-root"
	vim.opt.packpath:prepend(root_data .. "/site")
	vim.opt.runtimepath:prepend(root_data .. "/site")
	-- Prevent root from writing shada to your user home
	vim.opt.shadafile = "/root/.local/state/nvim-root.shada"
end
