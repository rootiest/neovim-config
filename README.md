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
- **Resilient & Portable**: Intelligent terminal title management (Kitty + Fallback) and automatic project root detection.
- **Lean & Readable**: ~741 lines of Lua code (excluding comments and blanks).

## 📁 Architecture

The configuration is strictly modular:

- `init.lua`: Entry point and global state initialization.
- `lua/lazyload.lua`: Logic for async and phased plugin loading.
- `lua/options.lua`: Global Vim settings, root management, and terminal title logic.
- `lua/plugins.lua`: Plugin declarations and detailed registry-based configurations.
- `lua/keymaps.lua`: Centralized user-facing keybindings.
- `lua/const.lua`: Stores constant values (like dashboard headers) for the configuration.

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

1.  **Build Blink**: If completion isn't working, run `cargo build --release` inside `~/.local/share/nvim/site/pack/core/opt/blink.cmp`.
2.  **LSP Servers**: Run `:Mason` to monitor the installation of Language Servers.
3.  **Copilot**: Run `:LspCopilotSignIn` to authenticate.

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
| `:Q` | Forced Write-All and Quit |

## 📜 License

Distributed under the **GPLv3 or later** License. See `LICENSE` for more information.
