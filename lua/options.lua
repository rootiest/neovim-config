--[[
  ┌────────────────────────────────────────────────────────────────┐
  │                            Options                             │
  └────────────────────────────────────────────────────────────────┘
--]]

---- Copyright (C) 2026 Rootiest
-- SPDX-License-Identifier: GPL-3.0-or-later

--          ╭─────────────────────────────────────────────────────────╮
--          │                      Basic Options                      │
--          ╰─────────────────────────────────────────────────────────╯

-- Set leader keys before any other configuration
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Indentation
vim.opt.tabstop = 2 -- Tab width in spaces
vim.opt.shiftwidth = 2 -- Indent width for >> and auto-indent
vim.opt.expandtab = true -- Use spaces instead of tabs

-- Performance and UI defaults
vim.opt.updatetime = 200 -- Faster completion and CursorHold events
vim.opt.autowrite = true -- Enable auto write
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers

--          ╭─────────────────────────────────────────────────────────╮
--          │                   Sessions and Saving                   │
--          ╰─────────────────────────────────────────────────────────╯

-- Persistent undo across sessions
vim.opt.undofile = true

-- Autowrite/Autosave
-- This ensures changes are saved on every buffer change or when leaving insert mode.
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	group = vim.api.nvim_create_augroup("autosave", { clear = true }),
	pattern = { "*" },
	callback = function()
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
		if buftype == "" and vim.bo.modified then
			vim.cmd("silent! update")
		end
	end,
})

-- Automatically reload files changed outside of Neovim
vim.opt.autoread = true

-- Auto-reload Triggers
-- Reload when focus is gained or when the cursor is idle
vim.api.nvim_create_autocmd({ "FocusGained", "CursorHold" }, {
	group = vim.api.nvim_create_augroup("autoread_on_focus", { clear = true }),
	pattern = "*",
	callback = function()
		-- Only if the buffer is not modified, to avoid losing unsaved changes
		if vim.bo.modified == false then
			vim.cmd("checktime")
		end
	end,
})

-- Format Function
-- Formats the entire buffer by default,
-- but if a range is provided (e.g., via visual selection),
-- it formats only that range.
vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

-- FormatOnSave
-- Formats the buffer before saving.
-- This is a common practice to ensure code is consistently formatted.
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		-- Call Format function
		vim.api.nvim_command("Format")
	end,
})

-- Return to last-known cursor position when reopening files
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Jump to last known cursor position on open",
  pattern = "*",
  callback = function()
    local last_pos = vim.fn.line("'\"")
    if last_pos > 1 and last_pos <= vim.fn.line("$") then
      vim.cmd('normal! g`\"')
    end
  end,
})

--          ╭─────────────────────────────────────────────────────────╮
--          │                     Root Management                     │
--          ╰─────────────────────────────────────────────────────────╯

-- Automatically change the working directory to the project root.
-- This ensures that plugins like Snacks.picker and GrugFar work
-- relative to the file or project you are currently editing.
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("buffer_auto_cd", { clear = true }),
	callback = function()
		local path = vim.api.nvim_buf_get_name(0)
		if path == "" then
			return
		end

		-- Skip special buffers, but allow directory buffers (for explorer support)
		if vim.bo.buftype ~= "" and vim.bo.filetype ~= "snacks_explorer_tree" then
			return
		end

		-- Get the directory (handle both files and directory paths)
		local dir = vim.fn.isdirectory(path) == 1 and path or vim.fn.fnamemodify(path, ":p:h")

		-- Find the project root using common markers, fallback to the directory itself
		local root = vim.fs.root(dir, { ".git", "lua", "package.json", "go.mod", "Cargo.toml", "Makefile" }) or dir

		-- Change directory if it's different and valid
		if root and vim.fn.isdirectory(root) == 1 and root ~= vim.fn.getcwd() then
			vim.fn.chdir(root)
		end
	end,
})

-- Grug-far QoL: Close with 'q'
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("grug_far_q_to_close", { clear = true }),
	pattern = "grug-far",
	callback = function(args)
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true, desc = "Close Grug-far" })
	end,
})

--          ╭─────────────────────────────────────────────────────────╮
--          │                    Shell Interaction                    │
--          ╰─────────────────────────────────────────────────────────╯

-- Detect terminal environment
local is_kitty = os.getenv("KITTY_PID") ~= nil
local current_shell = os.getenv("SHELL") or "/bin/sh"
local shell_name = current_shell:match("([^/]+)$") or "sh"

-- Terminal Title Management
local title_group = vim.api.nvim_create_augroup("TerminalTitle", { clear = true })

-- Helper function to update the terminal title
local function set_terminal_title(title)
	-- If in Kitty, we use the direct escape sequence as it's reliable
	if is_kitty then
		io.stdout:write("\27]2;" .. title .. "\7")
	-- Fallback: Use Neovim's built-in title management for other terminals
	-- (Standard OSC 2 sequences are supported by most, but opt.title is safer)
	elseif os.getenv("TERM") ~= "linux" then
		vim.opt.title = true
		vim.opt.titlestring = title
	end
end

-- Terminal title updates on buffer enter and window enter
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	group = title_group,
	callback = function()
		local buftype = vim.bo.buftype
		local filetype = vim.bo.filetype
		local filename = vim.fn.expand("%:t")

		-- 1. Specifically catch Snacks Terminal or standard Terminals
		if filetype == "snacks_terminal" or buftype == "terminal" then
			set_terminal_title("NVIM: Terminal")

		-- 2. Handle normal files (buftype is empty)
		elseif buftype == "" and filename ~= "" then
			set_terminal_title("NVIM: " .. filename)

		-- 3. Handle the empty start screen
		elseif filename == "" and buftype == "" then
			set_terminal_title("Neovim")
		end
	end,
})

-- Reset the title back to the shell name when you quit Neovim
vim.api.nvim_create_autocmd("VimLeave", {
	group = title_group,
	callback = function()
		-- On leave, direct stdout is more reliable than setting an option
		if is_kitty or os.getenv("TERM") ~= "linux" then
			io.stdout:write("\27]2;" .. shell_name .. "\7")
		end
	end,
})
