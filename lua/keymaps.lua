--[[
  ┌────────────────────────────────────────────────────────────────┐
  │                            Keymaps                             │
  └────────────────────────────────────────────────────────────────┘
--]]

---- Copyright (C) 2026 Rootiest
-- SPDX-License-Identifier: GPL-3.0-or-later

-- System Clipboard Integration
-- This makes 'y' and 'p' (and all other yank/paste operations)
-- use the system clipboard by default.
vim.opt.clipboard = "unnamedplus"

----------------------------------------------------------

-- Redirect 'delete' and 'change' operations to the 'd' register
-- This keeps your system clipboard (unnamedplus) clean
local delete_keys = { "d", "D", "c", "C", "x", "X" }
for _, key in ipairs(delete_keys) do
	vim.keymap.set({ "n", "v" }, key, '"d' .. key, { noremap = true, silent = true })
end

-- If you ever need to paste what you just deleted:
-- Type "dp (instead of just p)

----------------------------------------------------------

-- Quit and Save All with :Q
-- Replaces safety-checked :xa with a forced write-all-and-quit.
vim.api.nvim_create_user_command("Q", "xa!", { desc = "Write all and quit (forced)" })

----------------------------------------------------------

-- Search and Replace (Grug-far)
vim.keymap.set("n", "<leader>sr", function()
	require("grug-far").open({
		prefills = {
			search = vim.fn.expand("<cword>"),
		},
	})
end, { desc = "Search and Replace" })

-- Snacks Keymaps
-- Top Pickers & Explorer
vim.keymap.set("n", "<leader><space>", function()
	Snacks.picker.smart()
end, { desc = "Smart Find Files" })
vim.keymap.set("n", "<leader>,", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", function()
	Snacks.picker.grep()
end, { desc = "Grep" })
vim.keymap.set("n", "<leader>:", function()
	Snacks.picker.command_history()
end, { desc = "Command History" })
vim.keymap.set("n", "<leader>n", function()
	Snacks.picker.notifications()
end, { desc = "Notification History" })
vim.keymap.set("n", "<leader>e", function()
	Snacks.explorer()
end, { desc = "File Explorer" })

-- Find
vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fc", function()
	Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.git_files()
end, { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker.projects()
end, { desc = "Projects" })
vim.keymap.set("n", "<leader>fr", function()
	Snacks.picker.recent()
end, { desc = "Recent" })

-- Git
vim.keymap.set("n", "<leader>gb", function()
	Snacks.picker.git_branches()
end, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gl", function()
	Snacks.picker.git_log()
end, { desc = "Git Log" })
vim.keymap.set("n", "<leader>gL", function()
	Snacks.picker.git_log_line()
end, { desc = "Git Log Line" })
vim.keymap.set("n", "<leader>gs", function()
	Snacks.picker.git_status()
end, { desc = "Git Status" })
vim.keymap.set("n", "<leader>gS", function()
	Snacks.picker.git_stash()
end, { desc = "Git Stash" })
vim.keymap.set("n", "<leader>gd", function()
	Snacks.picker.git_diff()
end, { desc = "Git Diff (Hunks)" })
vim.keymap.set("n", "<leader>gf", function()
	Snacks.picker.git_log_file()
end, { desc = "Git Log File" })

-- GH
vim.keymap.set("n", "<leader>gi", function()
	Snacks.picker.gh_issue()
end, { desc = "GitHub Issues (open)" })
vim.keymap.set("n", "<leader>gI", function()
	Snacks.picker.gh_issue({ state = "all" })
end, { desc = "GitHub Issues (all)" })
vim.keymap.set("n", "<leader>gp", function()
	Snacks.picker.gh_pr()
end, { desc = "GitHub Pull Requests (open)" })
vim.keymap.set("n", "<leader>gP", function()
	Snacks.picker.gh_pr({ state = "all" })
end, { desc = "GitHub Pull Requests (all)" })

-- Grep
vim.keymap.set("n", "<leader>sb", function()
	Snacks.picker.lines()
end, { desc = "Buffer Lines" })
vim.keymap.set("n", "<leader>sB", function()
	Snacks.picker.grep_buffers()
end, { desc = "Grep Open Buffers" })
vim.keymap.set("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "Grep" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "Visual selection or word" })

-- Search
vim.keymap.set("n", '<leader>s"', function()
	Snacks.picker.registers()
end, { desc = "Registers" })
vim.keymap.set("n", "<leader>s/", function()
	Snacks.picker.search_history()
end, { desc = "Search History" })
vim.keymap.set("n", "<leader>sa", function()
	Snacks.picker.autocmds()
end, { desc = "Autocmds" })
vim.keymap.set("n", "<leader>sc", function()
	Snacks.picker.command_history()
end, { desc = "Command History" })
vim.keymap.set("n", "<leader>sC", function()
	Snacks.picker.commands()
end, { desc = "Commands" })
vim.keymap.set("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>sD", function()
	Snacks.picker.diagnostics_buffer()
end, { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "Help Pages" })
vim.keymap.set("n", "<leader>sH", function()
	Snacks.picker.highlights()
end, { desc = "Highlights" })
vim.keymap.set("n", "<leader>si", function()
	Snacks.picker.icons()
end, { desc = "Icons" })
vim.keymap.set("n", "<leader>sj", function()
	Snacks.picker.jumps()
end, { desc = "Jumps" })
vim.keymap.set("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>sl", function()
	Snacks.picker.loclist()
end, { desc = "Location List" })
vim.keymap.set("n", "<leader>sm", function()
	Snacks.picker.marks()
end, { desc = "Marks" })
vim.keymap.set("n", "<leader>sM", function()
	Snacks.picker.man()
end, { desc = "Man Pages" })
vim.keymap.set("n", "<leader>sp", function()
	Snacks.picker.lazy()
end, { desc = "Search for Plugin Spec" })
vim.keymap.set("n", "<leader>sq", function()
	Snacks.picker.qflist()
end, { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>sR", function()
	Snacks.picker.resume()
end, { desc = "Resume" })
vim.keymap.set("n", "<leader>su", function()
	Snacks.picker.undo()
end, { desc = "Undo History" })
vim.keymap.set("n", "<leader>uC", function()
	Snacks.picker.colorschemes()
end, { desc = "Colorschemes" })

-- LSP
vim.keymap.set("n", "gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Goto Definition" })
vim.keymap.set("n", "gD", function()
	Snacks.picker.lsp_declarations()
end, { desc = "Goto Declaration" })
vim.keymap.set("n", "gr", function()
	Snacks.picker.lsp_references()
end, { nowait = true, desc = "References" })
vim.keymap.set("n", "gI", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Goto Implementation" })
vim.keymap.set("n", "gy", function()
	Snacks.picker.lsp_type_definitions()
end, { desc = "Goto T[y]pe Definition" })
vim.keymap.set("n", "gai", function()
	Snacks.picker.lsp_incoming_calls()
end, { desc = "C[a]lls Incoming" })
vim.keymap.set("n", "gao", function()
	Snacks.picker.lsp_outgoing_calls()
end, { desc = "C[a]lls Outgoing" })
vim.keymap.set("n", "<leader>ss", function()
	Snacks.picker.lsp_symbols()
end, { desc = "LSP Symbols" })
vim.keymap.set("n", "<leader>sS", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "LSP Workspace Symbols" })

-- Standard LSP
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>cr", function()
	return ":" .. require("inc_rename").config.cmd_name .. " " .. vim.fn.expand("<cword>")
end, { expr = true, desc = "Rename Symbol" })

-- Other
vim.keymap.set("n", "<leader>sq", "<cmd>nohlsearch<cr>", { desc = "Clear Search Highlights" })
vim.keymap.set("n", "<leader>z", function()
	Snacks.zen()
end, { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>Z", function()
	Snacks.zen.zoom()
end, { desc = "Toggle Zoom" })
vim.keymap.set("n", "<leader>.", function()
	Snacks.scratch()
end, { desc = "Toggle Scratch Buffer" })
vim.keymap.set("n", "<leader>S", function()
	Snacks.scratch.select()
end, { desc = "Select Scratch Buffer" })
vim.keymap.set("n", "<leader>n", function()
	Snacks.notifier.show_history()
end, { desc = "Notification History" })
vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>cR", function()
	Snacks.rename.rename_file()
end, { desc = "Rename File" })
vim.keymap.set({ "n", "v" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse" })
vim.keymap.set("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>un", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })
vim.keymap.set({ "n", "t" }, "<c-/>", function()
	Snacks.terminal()
end, { desc = "Toggle Terminal" })
vim.keymap.set({ "n", "t" }, "<c-_>", function()
	Snacks.terminal()
end, { desc = "which_key_ignore" })
vim.keymap.set({ "n", "t" }, "]]", function()
	Snacks.words.jump(vim.v.count1)
end, { desc = "Next Reference" })
vim.keymap.set({ "n", "t" }, "[[", function()
	Snacks.words.jump(-vim.v.count1)
end, { desc = "Prev Reference" })
vim.keymap.set("n", "<leader>N", function()
	Snacks.win({
		file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
		width = 0.6,
		height = 0.6,
		wo = {
			spell = false,
			wrap = false,
			signcolumn = "yes",
			statuscolumn = " ",
			conceallevel = 3,
		},
	})
end, { desc = "Neovim News" })

----------------------------------------------------------

-- Sidekick NES: accept next-edit suggestion in normal mode
vim.keymap.set("n", "<Tab>", function()
	require("sidekick").nes_jump_or_apply()
end, { desc = "Apply Sidekick NES Suggestion" })

----------------------------------------------------------

-- Leap Keymaps
vim.keymap.set({ "n", "x", "o" }, "<CR>", "<Plug>(leap)")
vim.keymap.set("n", "S", "<Plug>(leap-from-window)")

----------------------------------------------------------

-- Conform Keymaps
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format Buffer" })

----------------------------------------------------------

-- Undotree Keymaps
vim.keymap.set("n", "<leader>uu", "<cmd>UndotreeToggle<cr>", { desc = "Toggle Undotree" })

----------------------------------------------------------

-- Comment Box Keymaps
vim.keymap.set({ "n", "v" }, "<leader>cbb", "<cmd>CBccbox<cr>", { desc = "Centered Box" })
vim.keymap.set({ "n", "v" }, "<leader>cbl", "<cmd>CBcline<cr>", { desc = "Centered Line" })
vim.keymap.set({ "n", "v" }, "<leader>cbd", "<cmd>CBd<cr>", { desc = "Delete Box/Line" })
vim.keymap.set("n", "<leader>cbk", "<cmd>CBcatalog<cr>", { desc = "Box Style Catalog" })

----------------------------------------------------------

-- Persistence Keymaps
vim.keymap.set("n", "<leader>qs", function()
	require("persistence").load()
end, { desc = "Restore Session" })
vim.keymap.set("n", "<leader>qS", function()
	require("persistence").select()
end, { desc = "Select Session" })
vim.keymap.set("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, { desc = "Restore Last Session" })
vim.keymap.set("n", "<leader>qd", function()
	require("persistence").stop()
end, { desc = "Don't Save Current Session" })

----------------------------------------------------------

-- Haunt Keymaps
vim.keymap.set("n", "<leader>ha", function()
	require("haunt.api").annotate()
end, { desc = "Annotate" })
vim.keymap.set("n", "<leader>ht", function()
	require("haunt.api").toggle_annotation()
end, { desc = "Toggle Annotation" })
vim.keymap.set("n", "<leader>hd", function()
	require("haunt.api").delete()
end, { desc = "Delete Bookmark" })
vim.keymap.set("n", "<leader>hn", function()
	require("haunt.api").next()
end, { desc = "Next Bookmark" })
vim.keymap.set("n", "<leader>hp", function()
	require("haunt.api").prev()
end, { desc = "Previous Bookmark" })
vim.keymap.set("n", "<leader>hl", function()
	require("haunt.picker").show()
end, { desc = "Show Bookmark Picker" })
