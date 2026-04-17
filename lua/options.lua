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
