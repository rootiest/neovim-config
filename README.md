# 🌙 Rootiest Neovim

A modern, modular, and high-performance Neovim configuration built from scratch with a focus on simplicity, speed, and standard Neovim primitives.

![Neovim](https://img.shields.io/badge/Neovim-0.10+-blue?logo=neovim)
![License](https://img.shields.io/badge/License-GPLv3+-green)

## ✨ Highlights

- **Built-in Package Management**: Exclusively uses `vim.pack` for lightweight, native plugin management.
- **Phased Loading**: Async, non-blocking startup using a phased `VimEnter` queue for a snappy experience.
- **Unified Registry**: Configuration is managed via a global `_G.Config` registry, ensuring cross-plugin consistency.
- **High Performance**: Featuring **blink.cmp** (Rust-based completion) and optimized **Snacks.nvim** components.
- **AI-Powered**: Native integration with the **GitHub Copilot Language Server**.
- **User-Centric QoL**: Hybrid line numbers, autosave-on-edit, and seamless system clipboard integration.
- **Resilient & Portable**: Intelligent terminal title management (Kitty + Fallback), automatic project root detection, and machine-local override support.
- **Lean & Readable**: ~850 lines of Lua code (excluding comments and blanks).

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
- **Nvim-web-devicons**: Consistent icons across UI components.

### Editing & Navigation
- **Flash**: Enhanced motion and search.
- **Focusline**: Keeps the active line at a configurable screen position (30%) during scrolling motions.
- **Mini.ai**: Better text objects (including `g` for entire buffer).
- **Mini.surround**: Surround text objects (add/delete/change).
- **Mini.pairs**: Auto-close brackets and quotes.
- **Persistence**: Session management.
- **Which-key**: Interactive keybinding documentation.
- **Gitsigns**: In-buffer git indicators and line highlights.
- **Grug-far**: Project-wide search and replace.
- **Gx.nvim**: Smart URL/reference opener under cursor.
- **Comment-box**: Decorative comment boxes and lines.
- **Undotree**: Visual undo history browser.
- **Zen Mode**: Distraction-free editing.
- **Qalc**: Inline calculator via `qalculate`.

### LSP & Completion
- **Blink.cmp** + **blink.lib**: High-performance Rust-based completion. Auto-detects binary across install layouts; falls back gracefully if unavailable. Rebuilds automatically on `PackChanged`.
- **LSPConfig + Mason**: Managed LSP support for Lua, C/C++, Rust, Python, Fish, and Shell.
- **Copilot**: GitHub Copilot language server integration.
- **Conform**: Formatter with format-on-save and range formatting.
- **Inc-rename**: Incremental LSP rename with live preview.
- **Lazydev**: Neovim Lua type definitions for `lua_ls`.

### Terminal
- **Kitty Scrollback**: Browse Kitty terminal scrollback buffer inside Neovim.

## 🛠️ System Dependencies

To ensure all features (pickers, formatters, and LSPs) work correctly, the following packages are required:

### Essential Tools
- `git`, `curl`, `unzip`, `build-essential` (or `base-devel`)
- `ripgrep` (Grep support)
- `fd` (Fast file finding)
- `fzf` (Fuzzy finder fallback)
- `lazygit` (Git TUI)
- `gh` (GitHub CLI integration)
- `xclip` / `xsel` (X11) or `wl-copy` (Wayland) for clipboard sync.

### Runtime Environments
- `Node.js` & `npm` (Copilot and various LSPs)
- `Python3` & `pip` (Python LSPs)
- `Cargo` (Rust toolchain, required for building `blink.cmp`)
- `qalculate` (optional, required for the Qalc calculator plugin)

### Installation Commands

**Debian / Ubuntu:**
```bash
sudo apt install git ripgrep fd-find fzf lazygit gh xclip nodejs npm build-essential curl unzip
```

**Arch Linux:**
```bash
sudo pacman -S git ripgrep fd fzf lazygit github-cli xclip nodejs npm base-devel curl unzip
```

## 🚀 Getting Started

### Installation

```bash
git clone https://github.com/your-username/nvim-config ~/.config/nvim
nvim
```

### Post-Install

1.  **Build Blink**: Completion auto-rebuilds on `PackChanged`. If it still isn't working, run `cargo build --release` inside `~/.local/share/nvim/site/pack/core/opt/blink.cmp`.
2.  **LSP Servers**: Run `:Mason` to monitor the installation of Language Servers.
3.  **Copilot**: Run `:LspCopilotSignIn` to authenticate.

### Machine-Local Overrides

Place machine-specific or secret configuration in `~/.config/.user-dots/nvim/local.lua` or `~/.config/.user-dots/nvim/secrets.lua`. These files are sourced automatically at startup if present, and are intentionally outside the repo to avoid accidental commits.

## ⌨️ Key Features & Mappings

| Key | Description |
| :--- | :--- |
| `<leader><space>` | Smart Find Files (Snacks) |
| `<leader>e` | File Explorer (Snacks) |
| `<leader>sr` | Search and Replace (Grug-far) |
| `<leader>gg` | Open Lazygit |
| `<leader>qs` | Restore Last Session (Persistence) |
| `<leader>cf` | Format Buffer (Conform) |
| `<leader>uu` | Toggle Undo Tree |
| `<leader>z` | Toggle Zen Mode |
| `gd` / `gr` | Goto Definition / References |
| `K` | Hover Documentation |
| `s` / `S` | Leap Motion (Normal/Window) |
| `ys` / `ds` / `cs` | Surround (Add/Delete/Change) |
| `gx` / `gX` | Open URL under cursor (Gx.nvim) |
| `<leader>cbb` | Create Centered Comment Box |
| `<leader>cbl` | Create Centered Comment Line |
| `<leader>cbd` | Delete Comment Box/Line |
| `<leader>cbk` | Browse Box Style Catalog |
| `:Q` | Forced Write-All and Quit |

## 📜 License

Distributed under the **GPLv3 or later** License. See `LICENSE` for more information.
