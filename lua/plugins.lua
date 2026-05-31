--[[
  ┌────────────────────────────────────────────────────────────────┐
  │                            Plugins                             │
  └────────────────────────────────────────────────────────────────┘
--]]

---- Copyright (C) 2026 Rootiest
-- SPDX-License-Identifier: GPL-3.0-or-later

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
					["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
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
			sidekick_send = function(...)
				return require("sidekick.cli.picker.snacks").send(...)
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

	-- Focusline.nvim
	vim.pack.add({
		{ src = "https://github.com/ABDsheikho/focusline.nvim" },
	})

	require("focusline").setup({
		-- focus_target can be a line number (e.g., 15), or a ratio (e.g., 0.25, 1 / 4, "25%").
		focus_target = "30%", -- try it with 30%
		-- which motion to associate focusline with.
		with_motion = {
			"zz",
			"z,",
			"\x04", -- Ctrl+D
			"\x15", -- Ctrl+U
		},
	})

	-- Mini.surround
	vim.pack.add({ { src = "https://github.com/echasnovski/mini.surround", name = "mini.surround" } })
	require("mini.surround").setup()

	-- Mini.pairs
	vim.pack.add({ { src = "https://github.com/echasnovski/mini.pairs", name = "mini.pairs" } })
	require("mini.pairs").setup()

	-- Gx.nvim
	vim.pack.add({ { src = "https://github.com/chrishrb/gx.nvim", name = "gx" } })
	---@diagnostic disable-next-line: missing-fields
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
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
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
	local has_blink_bin =
		-- Check v2 location (most likely where it is now)
		vim.fn.filereadable(blink_path .. "/lua/blink/cmp/lib/libblink_cmp_fuzzy.so") == 1
		-- Check v1/Cargo location (fallback)
		or vim.fn.filereadable(blink_path .. "/target/release/libblink_cmp_fuzzy.so") == 1
		-- Check macOS/Windows extensions
		or vim.fn.filereadable(blink_path .. "/target/release/libblink_cmp_fuzzy.dylib") == 1
		or vim.fn.filereadable(blink_path .. "/target/release/libblink_cmp_fuzzy.dll") == 1

	local has_cargo = vim.fn.executable("cargo") == 1

	if has_blink_bin or has_cargo then
		-- 1. Add blink.lib first as it's a dependency for blink.cmp
		vim.pack.add({ { src = "https://github.com/saghen/blink.lib", name = "blink.lib" } })

		-- 2. Add blink.cmp and other sources
		vim.pack.add({ { src = "https://github.com/saghen/blink.cmp", name = "blink.cmp" } })
		vim.pack.add({ { src = "https://github.com/rafamadriz/friendly-snippets", name = "friendly-snippets" } })
		vim.pack.add({ { src = "https://github.com/fang2hou/blink-copilot", name = "blink-copilot" } })

		-- 3. Blink.cmp setup
		require("blink.cmp").setup({
			keymap = {
				preset = "default",
				["<Tab>"] = {
					"snippet_forward",
					function()
						return require("sidekick").nes_jump_or_apply()
					end,
					function()
						return vim.lsp.inline_completion.get()
					end,
					"fallback",
				},
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
				kind_icons = { Copilot = "" },
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

	-- Autocmd to build blink.cmp after plugin installation or update
	vim.api.nvim_create_autocmd("User", {
		pattern = "PackChanged", -- This triggers after vim.pack.update() finishes
		callback = function()
			-- Check if blink is actually installed before trying to build
			local status, blink = pcall(require, "blink.cmp")
			if status then
				vim.notify("Blink.cmp: Building native library...", vim.log.levels.INFO)
				---@diagnostic disable-next-line: undefined-field
				blink.build():wait(60000)
				vim.notify("Blink.cmp: Build complete.", vim.log.levels.INFO)
			end
		end,
	})

	local lspconfig = require("lspconfig")
	local capabilities = (has_blink_bin or has_cargo) and require("blink.cmp").get_lsp_capabilities() or nil

	vim.lsp.config("rust_analyzer", {
		settings = {
			["rust-analyzer"] = {
				check = {
					command = "clippy",
				},
			},
		},
	})

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
			["rust_analyzer"] = function()
				lspconfig.rust_analyzer.setup({
					capabilities = capabilities,
					settings = {
						["rust-analyzer"] = {
							check = {
								command = "clippy",
							},
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
					---@diagnostic disable-next-line: undefined-field
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
	require("inc_rename").setup({
		-- the name of the command
		cmd_name = "IncRename",
		-- the highlight group used for highlighting the identifier's new name
		hl_group = "Substitute",
		-- whether an empty new name should be previewed; if false the command preview will be cancelled instead
		preview_empty_name = false,
		-- whether to display a `Renamed m instances in n files` message after a rename operation
		show_message = true,
		-- whether to save the "IncRename" command in the commandline history (set to false to prevent issues with
		-- navigating to older entries that may arise due to the behavior of command preview)
		save_in_cmdline_history = true,
		-- the type of the external input buffer to use (currently supports "dressing" or "snacks")
		input_buffer_type = nil,
		-- callback to run after renaming, receives the result table (from LSP handler) as an argument
		post_hook = nil,
	})

	-- Qalc
	vim.pack.add({ { src = "https://github.com/Apeiros-46B/qalc.nvim", name = "qalc" } })

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
		routes = {
			{
				filter = { event = "lsp", kind = "progress", find = "Loading workspace" },
				opts = { skip = true },
			},
			{
				filter = { event = "lsp", kind = "progress", find = "^Diagnosing" },
				opts = { skip = true },
			},
			{
				filter = { event = "lsp", kind = "progress", find = "semantic tokens" },
				opts = { skip = true },
			},
		},
	})

	-- Kitty Scrollback
	vim.pack.add({ { src = "https://github.com/mikesmithgh/kitty-scrollback.nvim", name = "kitty-scrollback" } })
	Config.plugins.kitty_scrollback = {}
	require("kitty-scrollback").setup(Config.plugins.kitty_scrollback)

	-- Haunt.nvim
	vim.pack.add({ { src = "https://github.com/TheNoeTrevino/haunt.nvim", name = "haunt" } })
	Config.plugins.haunt = {
		picker = "snacks",
	}
	require("haunt").setup(Config.plugins.haunt)

	-- Sidekick.nvim
	vim.pack.add({ { src = "https://github.com/folke/sidekick.nvim", name = "sidekick" } })
	Config.plugins.sidekick = {
		cli = {
			prompts = {
				haunt_all = function()
					return require("haunt.sidekick").get_locations()
				end,
				haunt_buffer = function()
					return require("haunt.sidekick").get_locations({ current_buffer = true })
				end,
			},
		},
	}
	require("sidekick").setup(Config.plugins.sidekick)
end)
