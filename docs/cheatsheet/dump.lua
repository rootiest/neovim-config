-- Dump the live keymap/command state of this config as JSON.
--
-- Run by gen_cheatsheet.py as:
--   CHEATSHEET_DUMP=out.json nvim --headless -V1 -c "luafile /abs/path/dump.lua"
-- -V1 makes Neovim record "last set from <file>:<line>" for Lua mappings,
-- which is how each map is attributed to the config, a plugin or the runtime.

local out = assert(vim.env.CHEATSHEET_DUMP, "set CHEATSHEET_DUMP to the output path")
local MODES = { "n", "x", "s", "o", "i", "c", "t" }
local SAMPLES = {
  { name = "lua", path = vim.fn.stdpath("config") .. "/lua/keymaps.lua", lsp = true },
  { name = "markdown", ft = "markdown" },
}

local function script_path(sid)
  if not sid or sid <= 0 then
    return nil
  end
  local info = vim.fn.getscriptinfo({ sid = sid })[1]
  if not info then
    return nil
  end
  -- Lua modules compiled into Neovim (vim/_core/defaults.lua, …) are reported
  -- by module path, which getscriptinfo() resolves against the cwd.
  local mod = info.name:match("/(vim/_core/.*)$")
  if mod and not vim.uv.fs_stat(info.name) then
    return vim.env.VIMRUNTIME .. "/lua/" .. mod .. (mod:match("%.lua$") and "" or ".lua")
  end
  return info.name
end

local function collect(maps, scope)
  local res = {}
  for _, m in ipairs(maps) do
    res[#res + 1] = {
      mode = m.mode,
      -- keytrans() turns a raw leader " " into <Space>, but would also fold
      -- <C-I>/<C-M>/<C-[> into <Tab>/<CR>/<Esc>, which map separately.
      lhs = m.lhs:find("<[Cc]%-[IiMm%[]>") and m.lhs
        or vim.fn.keytrans(vim.api.nvim_replace_termcodes(m.lhs, true, true, true)),
      rhs = m.rhs ~= "" and m.rhs or nil,
      callback = m.callback ~= nil or nil,
      desc = m.desc,
      expr = m.expr == 1 or nil,
      nowait = m.nowait == 1 or nil,
      file = script_path(m.sid),
      line = m.lnum ~= 0 and m.lnum or nil,
      scope = scope,
    }
  end
  return res
end

local function all_modes(get)
  local res = {}
  for _, mode in ipairs(MODES) do
    for _, m in ipairs(get(mode)) do
      -- nvim_get_keymap("x") etc. also report "v"/" " maps once per queried
      -- mode; keep the queried mode so every entry belongs to exactly one.
      m.mode = mode
      res[#res + 1] = m
    end
  end
  return res
end

local function commands(cmds, scope)
  local res = {}
  for name, c in pairs(cmds) do
    local file, line
    if c.script_id and c.script_id > 0 then
      file = script_path(c.script_id)
    end
    res[#res + 1] = {
      name = name,
      desc = c.definition ~= "" and c.definition or nil,
      nargs = c.nargs,
      range = c.range,
      bang = c.bang or nil,
      file = file,
      scope = scope,
    }
  end
  table.sort(res, function(a, b)
    return a.name < b.name
  end)
  return res
end

local function dump()
  local data = {
    version = tostring(vim.version()),
    vimruntime = vim.env.VIMRUNTIME,
    config = vim.fn.stdpath("config"),
    data = vim.fn.stdpath("data"),
    leader = vim.g.mapleader,
    localleader = vim.g.maplocalleader,
    neovide = vim.g.neovide and true or false,
    options = {
      clipboard = vim.o.clipboard,
      relativenumber = vim.o.relativenumber,
      timeoutlen = vim.o.timeoutlen,
      wrap = vim.o.wrap,
      ignorecase = vim.o.ignorecase,
      smartcase = vim.o.smartcase,
      autowrite = vim.o.autowrite,
      undofile = vim.o.undofile,
      shiftwidth = vim.o.shiftwidth,
    },
    maps = collect(all_modes(vim.api.nvim_get_keymap), "global"),
    commands = commands(vim.api.nvim_get_commands({ builtin = false }), "global"),
    buffers = {},
    plugins = {},
  }

  for _, p in ipairs(vim.pack.get()) do
    data.plugins[#data.plugins + 1] = { name = p.spec.name, src = p.spec.src, active = p.active }
  end

  -- Plugin-internal keys that only exist inside their own windows.
  local ok, snacks_cfg = pcall(function()
    return require("snacks.picker.config").get({})
  end)
  if ok then
    local function keys(t)
      local res = {}
      for lhs, v in pairs(t or {}) do
        if v then
          local action = type(v) == "table" and (v[1] or v.action) or v
          res[#res + 1] = {
            lhs = lhs,
            action = type(action) == "string" and action or "function",
            mode = type(v) == "table" and v.mode or nil,
            desc = type(v) == "table" and v.desc or nil,
          }
        end
      end
      return res
    end
    data.snacks_picker = {
      input = keys(snacks_cfg.win.input.keys),
      list = keys(snacks_cfg.win.list.keys),
      preview = keys(snacks_cfg.win.preview.keys),
    }
    local eok, explorer = pcall(function()
      return require("snacks.picker.config").get({ source = "explorer" })
    end)
    if eok then
      data.snacks_explorer = keys(explorer.win.list.keys)
    end
  end

  -- blink.cmp resolves its preset + overrides into keymap.mappings at setup.
  local bok, blink_keymap = pcall(require, "blink.cmp.keymap")
  if bok and blink_keymap.mappings then
    data.blink = {}
    for kind, mappings in pairs(blink_keymap.mappings) do
      local res = {}
      for lhs, actions in pairs(mappings) do
        local names = {}
        for _, a in ipairs(type(actions) == "table" and actions or {}) do
          names[#names + 1] = type(a) == "string" and a or "function"
        end
        res[#res + 1] = { lhs = lhs, actions = names }
      end
      data.blink[kind] = res
    end
  end

  local fok, flash_cfg = pcall(function()
    return require("flash.config")
  end)
  if fok then
    data.flash = {
      char_keys = flash_cfg.modes.char.keys,
      multi_line = flash_cfg.modes.char.multi_line,
      jump_labels = flash_cfg.modes.char.jump_labels,
    }
  end

  local function sample(s)
    local buf
    if s.path then
      vim.cmd.edit(vim.fn.fnameescape(s.path))
      buf = vim.api.nvim_get_current_buf()
    else
      buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_set_current_buf(buf)
      vim.bo[buf].filetype = s.ft
    end
    if s.lsp then
      vim.wait(15000, function()
        return #vim.lsp.get_clients({ bufnr = buf }) > 0
      end, 100)
      vim.wait(500)
    end
    -- Plugins that attach on InsertEnter/BufEnter (blink.cmp, …).
    vim.api.nvim_exec_autocmds({ "BufEnter", "InsertEnter" }, { buffer = buf, modeline = false })
    local get = function(mode)
      return vim.api.nvim_buf_get_keymap(buf, mode)
    end
    data.buffers[#data.buffers + 1] = {
      name = s.name,
      filetype = vim.bo[buf].filetype,
      lsp = vim.tbl_map(function(c)
        return c.name
      end, vim.lsp.get_clients({ bufnr = buf })),
      maps = collect(all_modes(get), "buffer"),
      commands = commands(vim.api.nvim_buf_get_commands(buf, {}), "buffer"),
    }
  end
  for _, s in ipairs(SAMPLES) do
    local sok, err = pcall(sample, s)
    if not sok then
      io.stderr:write("sample " .. s.name .. " failed: " .. tostring(err) .. "\n")
    end
  end

  local f = assert(io.open(out, "w"))
  f:write(vim.json.encode(data))
  f:close()
  vim.cmd("qa!")
end

-- Plugins load on VimEnter (lua/lazyload.lua); wait for the last of them.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- Headless Neovim never fires UIEnter, which Snacks waits for before
    -- setting up UI-only maps (scope: ii/ai/[i/]i).
    vim.api.nvim_exec_autocmds("UIEnter", { modeline = false })
    vim.defer_fn(function()
      vim.wait(10000, function()
        return package.loaded["obsidian"] ~= nil and package.loaded["sidekick"] ~= nil
      end, 50)
      vim.defer_fn(dump, 300)
    end, 50)
  end,
})
