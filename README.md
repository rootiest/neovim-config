# 🌙 Rootiest Neovim

A modern, modular, and high-performance Neovim configuration built from scratch with a focus on simplicity, speed, and standard Neovim primitives.

![Neovim](https://img.shields.io/badge/Neovim-0.10+-blue?logo=neovim)
![License](https://img.shields.io/badge/License-GPLv3+-green)

📖 **[Interactive keymap cheatsheet](https://pages.rootiest.dev/neovim-config/cheatsheet/)**: every Vim key and every mapping in this config, searchable.

## ✨ Highlights

- **Built-in Package Management**: Exclusively uses `vim.pack` for lightweight, native plugin management.
- **Phased Loading**: Async, non-blocking startup using a phased `VimEnter` queue for a snappy experience.
- **Unified Registry**: Configuration is managed via a global `_G.Config` registry, ensuring cross-plugin consistency.
- **High Performance**: Featuring **blink.cmp** (Rust-based completion) and optimized **Snacks.nvim** components.
- **AI-Powered**: Native integration with **GitHub Copilot** — inline completions via **blink-copilot** and multi-line refactoring via **Sidekick.nvim** Next Edit Suggestions (NES).
- **User-Centric QoL**: Hybrid line numbers, autosave-on-edit, and seamless system clipboard integration.
- **Resilient & Portable**: Intelligent terminal title management (Kitty + Fallback), automatic project root detection, and machine-local override support.
- **Lean & Readable**: ~980 lines of Lua code (excluding comments and blanks).

## 📁 Architecture

The configuration is strictly modular:

- `init.lua`: Entry point, bootstrap, global state initialization, and machine-local overrides.
- `lua/bootstrap.lua`: Early runtime setup — redirects Neovim's data/state paths when running as root (e.g. via a symlinked `~/.config/nvim`), preventing root sessions from polluting or conflicting with the user-level install.
- `lua/lazyload.lua`: Logic for async and phased plugin loading.
- `lua/options.lua`: Global Vim settings, auto-reload, root management, and terminal title logic.
- `lua/plugins.lua`: Plugin declarations and detailed registry-based configurations.
- `lua/keymaps.lua`: Centralized user-facing keybindings.
- `lua/const.lua`: Stores constant values (like dashboard headers) for the configuration.

## 🔌 Plugin Stack

### Core UI
- **Catppuccin**: Primary colorscheme (Mocha flavour).
- **Lualine**: Statusline with Git diff and line-by-line Gitsigns blame.
- **Noice**: Modern UI for cmdline (popup), messages, and LSP hover.
- **Snacks**: High-performance dashboard, explorer, and pickers.
- **Snacks-tea**: Gitea/Forgejo extension for Snacks (via the `tea` CLI) — Pull Request picker, review, and creation UI, mirroring the built-in GitHub PR/issue integration.
- **Nvim-web-devicons**: Consistent icons across UI components.

### Editing & Navigation
- **Flash**: `f`/`F`/`t`/`T` with match highlighting, kept to the current line.
- **Leap**: Jump anywhere in the window with `<CR>` + two characters (`S` across windows).
- **Focusline**: Keeps the active line at a configurable screen position (30%) during scrolling motions.
- **Mini.ai**: Better text objects (including `g` for entire buffer).
- **Mini.surround**: Surround text objects (add/delete/change).
- **Mini.pairs** + `lua/smart_pairs.lua`: Context-aware auto-close for brackets, quotes and backticks — a closing character is only added when the rest of the line is empty/whitespace or a closing bracket, so wrapping existing text (e.g. adding backticks around a word) never inserts a stray closer; quotes don't pair after a word character. In Markdown, a 3rd `` ` `` or `~` on a blank line opens a fenced code block pair (only outside an existing block and with a blank line or the block's closer below); further characters lengthen both fences (` ```` `, ` ````` `), `<BS>` shrinks them, and fences nested inside a longer block pair as examples, collapsing into the enclosing block's closer once long enough to close it.
- **Persistence**: Session management.
- **Which-key**: Interactive keybinding documentation.
- **Gitsigns**: In-buffer git indicators and line highlights.
- **Grug-far**: Project-wide search and replace.
- **Gx.nvim**: Smart URL/reference opener under cursor.
- **Comment-box**: Decorative comment boxes and lines.
- **Undotree**: Visual undo history browser.
- **Haunt.nvim**: In-buffer annotation and bookmark manager. Integrates with the Snacks picker for browsing bookmarks and exposes `haunt_all` / `haunt_buffer` prompt contexts to Sidekick AI sessions.
- **Zen Mode**: Distraction-free editing.
- **Qalc**: Inline calculator via `qalculate`.
- **Obsidian.nvim**: Obsidian vault integration for note-taking and knowledge management, with `notebook` (`~/Documents/Notebook`) and `notes` (`~/Documents/Notes`) workspaces.

### LSP & Completion
- **Blink.cmp** + **blink.lib**: High-performance Rust-based completion. Auto-detects binary across install layouts; falls back gracefully if unavailable. Rebuilds automatically on `PackChanged`.
- **blink-copilot**: Surfaces GitHub Copilot inline suggestions inside the blink.cmp completion menu.
- **Sidekick.nvim**: AI assistant providing Next Edit Suggestions (NES) for multi-line refactoring via the Copilot LSP, plus an integrated AI CLI terminal (`:Sidekick cli toggle`) with context-aware prompts. Snacks picker integration sends selections to the active AI session via `<Alt-a>`.
- **LSPConfig + Mason**: Managed LSP support for Lua, C/C++, Rust, Python, Fish, and Shell.
- **Conform**: Formatter with format-on-save and range formatting.
- **Inc-rename**: Incremental LSP rename with live preview.
- **Lazydev**: Neovim Lua type definitions for `lua_ls`.

### Terminal
- **Kitty Scrollback**: Browse Kitty terminal scrollback buffer inside Neovim.
- **Neovide**: When running under the Neovide GUI, adds terminal-style system-clipboard keys: `Ctrl+Shift+V` paste (all modes; in Normal mode an empty line is replaced and the cursor lands after the paste), `Ctrl+Shift+C` copy and `Ctrl+Shift+X` cut (selection in Visual mode, current line in Normal mode).

### Tracking
- **Vim-wakatime**: Coding-time tracking. Loaded eagerly so it sees `VimEnter`/`BufEnter`; server and API key come from `~/.wakatime.cfg`. Reports as `neovim-wakatime` so Wakapi attributes time to Neovim instead of "Unknown".

## 🛠️ System Dependencies

To ensure all features (pickers, formatters, and LSPs) work correctly, the following packages are required:

### Essential Tools
- `git`, `curl`, `unzip`, `build-essential` (or `base-devel`)
- `ripgrep` (Grep support)
- `fd` (Fast file finding)
- `fzf` (Fuzzy finder fallback)
- `lazygit` (Git TUI)
- `gh` (GitHub CLI integration)
- `tea` (Gitea/Forgejo CLI integration, for Snacks-tea)
- `xclip` / `xsel` (X11) or `wl-copy` (Wayland) for clipboard sync.
- `wakatime-cli` (Optional, installed automatically for Wakatime tracking)

### Runtime Environments
- `Node.js` & `npm` (Copilot and various LSPs)
- `Python3` & `pip` (Python LSPs)
- `Cargo` (Rust toolchain, required for building `blink.cmp`)
- `qalculate` (optional, required for the Qalc calculator plugin)

### Installation Commands

**Debian / Ubuntu:**
```bash
sudo apt install git ripgrep fd-find fzf lazygit gh xclip nodejs npm build-essential curl unzip
# tea: no apt package; install via `go install gitea.com/gitea/tea@latest` or a release binary.
```

**Arch Linux:**
```bash
sudo pacman -S git ripgrep fd fzf lazygit github-cli tea xclip nodejs npm base-devel curl unzip
```

## 🚀 Getting Started

### Installation

```bash
git clone https://git.rootiest.dev/rootiest/neovim-config.git ~/.config/nvim
nvim
```

### Post-Install

1.  **Build Blink**: Completion auto-rebuilds on `PackChanged`. If it still isn't working, run `cargo build --release` inside `~/.local/share/nvim/site/pack/core/opt/blink.cmp`.
2.  **LSP Servers**: Run `:Mason` to monitor the installation of Language Servers.
3.  **Copilot**: Run `:LspCopilotSignIn` to authenticate, then `:checkhealth sidekick` to verify the Sidekick NES integration is working.

### Machine-Local Overrides

Place machine-specific or secret configuration in `~/.config/.user-dots/nvim/local.lua` or `~/.config/.user-dots/nvim/secrets.lua`. These files are sourced automatically at startup if present, and are intentionally outside the repo to avoid accidental commits.

## ⌨️ Key Features & Mappings

| Key | Description |
| :--- | :--- |
| `<leader><space>` | Smart Find Files (Snacks) |
| `<leader>e` | File Explorer (Snacks) |
| `j` / `k` / `↓` / `↑` | Move by wrapped (display) line when no count is given; counts still move by real lines. Arrows do the same in insert mode |
| `<leader>sr` | Search and Replace (Grug-far) |
| `<leader>gg` | Open Lazygit |
| `<leader>qs` / `<leader>ql` | Restore Session / Restore Last Session (Persistence) |
| `<leader>cf` | Format Buffer (Conform) |
| `<leader>uu` | Toggle Undo Tree |
| `<leader>z` | Toggle Zen Mode |
| `gd` / `grr` | Goto Definition / References (Snacks pickers); Neovim's `grn` `gra` `gri` `grt` stay available |
| `K` | Hover Documentation |
| `<CR>` / `S` | Leap Motion (Window/Across windows) |
| `sa` / `sd` / `sr` | Surround (Add/Delete/Replace, mini.surround) |
| `gx` | Open URL, file, plugin or issue under cursor (Gx.nvim) |
| `<Tab>` *(insert)* | Advance snippet → NES suggestion → native inline completion → fallback |
| `<Tab>` *(normal)* | Jump to / apply Sidekick NES suggestion, else jump forward |
| `<Alt-a>` *(picker)* | Send picker selection to active AI CLI session |
| `<leader>ha` | Annotate current position (Haunt) |
| `<leader>ht` | Toggle annotation visibility (Haunt) |
| `<leader>hd` | Delete bookmark (Haunt) |
| `<leader>hn` / `<leader>hp` | Next / Previous bookmark (Haunt) |
| `<leader>hl` | Browse all bookmarks in picker (Haunt) |
| `<leader>cbb` | Create Centered Comment Box |
| `<leader>cbl` | Create Centered Comment Line |
| `<leader>cbd` | Delete Comment Box/Line |
| `<leader>cbk` | Browse Box Style Catalog |
| `:Q` | Forced Write-All and Quit |

The full list, including built-in Vim keys and keys inside plugin windows, is in the cheatsheet below.

## 📖 Keymap Cheatsheet

**[pages.rootiest.dev/neovim-config/cheatsheet](https://pages.rootiest.dev/neovim-config/cheatsheet/)**: a single-page, searchable reference of every built-in Vim key plus this config's live keymaps, showing which built-ins a mapping replaces and where each mapping is defined. It also has an interactive keyboard, a leader-key tree, a text-object composer and the keys inside plugin windows (pickers, completion, Flash/Leap).

It is generated from Neovim's own help index, a headless dump of this config and curated notes in `docs/cheatsheet/curated/`. After changing keymaps, regenerate it:

```bash
python3 docs/cheatsheet/gen_cheatsheet.py
```

Pushing `docs/cheatsheet/cheatsheet.html` to `main` publishes it (`.github/workflows/pages.yml`).

## 📜 License

Distributed under the **GPLv3 or later** License. See `LICENSE` for more information.
