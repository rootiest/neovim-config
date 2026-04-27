--[[
  ┌────────────────────────────────────────────────────────────────┐
  │                            Plugins                             │
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

-- Catppuccin.nvim
-- Eagerly load the colorscheme plugin.
vim.pack.add({ { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } })

-- Catppuccin Config
Config.plugins.catppuccin = {
	flavour = "mocha",
}
vim.cmd.colorscheme("catppuccin")

-- Snacks.nvim
-- Eagerly load snacks for dashboard and performance features.
vim.pack.add({ { src = "https://github.com/folke/snacks.nvim", name = "snacks" } })

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
		preset = {
			header = require("const").header,
		},
	},
	explorer = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	picker = {
		enabled = true,
		matcher = {
			fuzzy = true,
			smartcase = true,
			ignorecase = true,
			sort_empty = false,
			filename_bonus = true,
			file_pos = true,
			cwd_bonus = true,
			frecency = true,
			history_bonus = true,
		},
		win = {
			input = {
				keys = {
					["<a-s>"] = { "flash", mode = { "n", "i" } },
					["s"] = { "flash" },
				},
			},
		},
		actions = {
			flash = function(picker)
				require("flash").jump({
					pattern = "^",
					label = { after = { 0, 0 } },
					search = {
						mode = "search",
						exclude = {
							function(win)
								return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
							end,
						},
					},
					action = function(match)
						local idx = picker.list:row2idx(match.pos[1])
						picker.list:_move(idx, true, true)
					end,
				})
			end,
		},
	},
	notifier = { enabled = true },
	quickfile = { enabled = true },
	scope = { enabled = true },
	scratch = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	terminal = {
		enabled = true,
		win = {
			keys = {
				toggle = {
					"<c-/>",
					function(self)
						self:hide()
					end,
					mode = "t",
					desc = "Toggle Terminal",
				},
			},
		},
	},
	words = { enabled = true },
	zen = { enabled = true },
}

-- Setup Snacks with the registered opts.
require("snacks").setup(Config.plugins.snacks)

-- Persistence.nvim
-- Simple session management.
vim.pack.add({ { src = "https://github.com/folke/persistence.nvim", name = "persistence" } })

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
	vim.pack.add({ { src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" } })
	require("gitsigns").setup({
		numhl = false,
		signcolumn = true,
		current_line_blame = true, -- Required for the statusline variable to update
		current_line_blame_opts = {
			virt_text = false, -- Disable virtual text as we'll use the statusline
		},
	})

	-- Treesitter Context
	vim.pack.add({
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context", name = "nvim-treesitter-context" },
	})
	require("treesitter-context").setup({
		max_lines = 3,
		trim_scope = "outer",
	})

	-- Grug-far.nvim
	vim.pack.add({ { src = "https://github.com/MagicDuck/grug-far.nvim", name = "grug-far" } })
	require("grug-far").setup()

	-- Flash.nvim
	vim.pack.add({ { src = "https://github.com/folke/flash.nvim", name = "flash" } })
	require("flash").setup({
		modes = { char = { keys = {} } },
		keys = {},
	})

	-- Leap.nvim
	vim.pack.add({ { src = "https://git.disroot.org/andyg/leap.nvim", name = "leap" } })
	vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })

	-- Mini.surround
	vim.pack.add({ { src = "https://github.com/echasnovski/mini.surround", name = "mini.surround" } })
	require("mini.surround").setup()

	-- Mini.pairs
	vim.pack.add({ { src = "https://github.com/echasnovski/mini.pairs", name = "mini.pairs" } })
	require("mini.pairs").setup()

	-- Gx.nvim
	vim.pack.add({ { src = "https://github.com/chrishrb/gx.nvim", name = "gx" } })
	require("gx").setup({
		handlers = {
			plugin = true,
			github = true,
			package_json = true,
			search = true,
		},
	})

	-- Comment-box.nvim
	vim.pack.add({ { src = "https://github.com/LudoPinelli/comment-box.nvim", name = "comment-box" } })
	require("comment-box").setup()

	-- Undotree
	vim.g.undotree_ShortIndicators = 0
	vim.g.undotree_SplitWidth = 32
	vim.g.undotree_SetFocusWhenToggle = 1
	vim.g.undotree_TreeNodeShape = ""
	vim.g.undotree_TreeVertShape = ""
	vim.g.undotree_TreeSplitShape = ""
	vim.g.undotree_TreeReturnShape = ""
	vim.g.undotree_HelpLine = 0
	vim.g.undotree_DiffAutoOpen = 0
	vim.pack.add({ { src = "https://github.com/mbbill/undotree", name = "undotree" } })

	-- Conform.nvim
	vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim", name = "conform" } })
	Config.plugins.conform = {
		formatters_by_ft = {
			lua = { "stylua" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			rust = { "rustfmt" },
			python = { "ruff_format" },
			fish = { "fish_indent" },
			sh = { "shfmt" },
			bash = { "shfmt" },
		},
		format_on_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
	}
	require("conform").setup(Config.plugins.conform)

	-- Which-key.nvim
	vim.pack.add({ { src = "https://github.com/folke/which-key.nvim", name = "which-key" } })
	require("which-key").setup()

	-- Lazydev.nvim (Neovim Lua type definitions for lua_ls)
	vim.pack.add({ { src = "https://github.com/folke/lazydev.nvim", name = "lazydev" } })
	require("lazydev").setup({
		library = {
			{ path = "snacks.nvim", words = { "Snacks" } },
		},
	})

	-- LSP Support
	vim.pack.add({ { src = "https://github.com/williamboman/mason.nvim", name = "mason" } })
	vim.pack.add({ { src = "https://github.com/williamboman/mason-lspconfig.nvim", name = "mason-lspconfig" } })
	vim.pack.add({ { src = "https://github.com/neovim/nvim-lspconfig", name = "nvim-lspconfig" } })

	require("mason").setup()

	-- Completion (Blink.cmp)
	-- We check if the binary exists or if cargo is available to build it.
	-- If neither, we skip loading to avoid errors.
	local blink_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp"
	local has_blink_bin = vim.fn.filereadable(blink_path .. "/target/release/libblink_cmp_fuzzy.so") == 1
		or vim.fn.filereadable(blink_path .. "/target/release/libblink_cmp_fuzzy.dylib") == 1
		or vim.fn.filereadable(blink_path .. "/target/release/libblink_cmp_fuzzy.dll") == 1
	local has_cargo = vim.fn.executable("cargo") == 1

	if has_blink_bin or has_cargo then
		vim.pack.add({ { src = "https://github.com/saghen/blink.cmp", name = "blink.cmp" } })
		vim.pack.add({ { src = "https://github.com/rafamadriz/friendly-snippets", name = "friendly-snippets" } })
		vim.pack.add({ { src = "https://github.com/fang2hou/blink-copilot", name = "blink-copilot" } })

		-- Blink.cmp setup
		require("blink.cmp").setup({
			keymap = { preset = "default" },
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
				kind_icons = {
					Copilot = "",
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "copilot" },
				providers = {
					copilot = {
						name = "copilot",
						module = "blink-copilot",
						kind = "lsp",
						server_name = "copilot",
						score_offset = 100,
						async = true,
						opts = {
							max_completions = 3,
							max_attempts = 4,
						},
					},
				},
			},
			signature = { enabled = true },
		})
	else
		vim.notify("blink.cmp: binary not found and cargo not installed. Completion disabled.", vim.log.levels.WARN)
	end

	local lspconfig = require("lspconfig")
	local capabilities = (has_blink_bin or has_cargo) and require("blink.cmp").get_lsp_capabilities() or nil

	require("mason-lspconfig").setup({
		ensure_installed = {
			"lua_ls",
			"clangd",
			"rust_analyzer",
			"pyright",
			"fish_lsp",
			"bashls",
			"copilot",
		},
		handlers = {
			-- Default handler
			function(server_name)
				lspconfig[server_name].setup({ capabilities = capabilities })
			end,
			-- Specific overrides
			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "Config" } },
						},
					},
				})
			end,
		},
	})

	-- Mini.ai
	vim.pack.add({ { src = "https://github.com/echasnovski/mini.ai", name = "mini.ai" } })

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
	vim.pack.add({ { src = "https://github.com/nvim-tree/nvim-web-devicons", name = "nvim-web-devicons" } })

	-- Lualine
	vim.pack.add({ { src = "https://github.com/nvim-lualine/lualine.nvim", name = "lualine" } })
	require("lualine").setup({
		options = {
			theme = "auto",
			globalstatus = true,
		},
		sections = {
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = {
				{ "filename" },
				{
					function()
						return vim.b.gitsigns_blame_line or ""
					end,
					cond = function()
						return vim.b.gitsigns_blame_line ~= nil and vim.b.gitsigns_blame_line ~= ""
					end,
				},
			},
		},
	})

	-- Inc-rename.nvim
	vim.pack.add({ { src = "https://github.com/smjonas/inc-rename.nvim", name = "inc-rename" } })
	require("inc_rename").setup()

	-- Noice dependencies
	vim.pack.add({ { src = "https://github.com/MunifTanjim/nui.nvim", name = "nui" } })

	-- Noice.nvim
	vim.pack.add({ { src = "https://github.com/folke/noice.nvim", name = "noice" } })
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
			inc_rename = true, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
	})
end)
