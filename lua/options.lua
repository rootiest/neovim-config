--[[
  ┌────────────────────────────────────────────────────────────────┐
  │                            Options                             │
  └────────────────────────────────────────────────────────────────┘
--]]

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

-- Performance and UI defaults
vim.opt.updatetime = 200 -- Faster completion and CursorHold events
vim.opt.autowrite = true -- Enable auto write
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers

-- Persistent undo across sessions
vim.opt.undofile = true

-- Indentation
vim.opt.tabstop = 2 -- Tab width in spaces
vim.opt.shiftwidth = 2 -- Indent width for >> and auto-indent
vim.opt.expandtab = true -- Use spaces instead of tabs

-- FormatOnSave
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

-- Execute Format
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
