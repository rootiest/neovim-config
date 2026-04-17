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

## 📁 Architecture

The configuration is strictly modular:

- `init.lua`: Entry point and global state initialization.
- `lua/lazyload.lua`: Logic for async and phased plugin loading.
- `lua/options.lua`: Global Vim settings and non-plugin autocommands.
- `lua/plugins.lua`: Plugin declarations and detailed registry-based configurations.
- `lua/keymaps.lua`: Centralized user-facing keybindings.
- `lua/const.lua`: Stores constant values for reference in the configuration.

## 🚀 Getting Started

### Prerequisites

- **Neovim 0.10+**
- **Nerd Font** (Mono variant recommended for optimal UI alignment)
- **Cargo** (Required for building `blink.cmp` fuzzy matching library)
- **Node.js** (Required for various LSPs and Copilot)

### Installation

```bash
git clone https://github.com/your-username/nvim-config ~/.config/nvim
nvim
```

### Post-Install

1.  **Build Blink**: If completion isn't working, run `cargo build --release` inside `~/.local/share/nvim/site/pack/core/opt/blink.cmp`.
2.  **LSP Servers**: Run `:Mason` to monitor the installation of Language Servers (Lua, C, Rust, Python, etc.).
3.  **Copilot**: Run `:LspCopilotSignIn` to authenticate with GitHub.

## ⌨️ Key Features & Mappings

| Key | Description |
| :--- | :--- |
| `<leader><space>` | Smart Find Files (Snacks) |
| `<leader>e` | File Explorer |
| `<leader>ff` | Find Files |
| `<leader>sg` | Project-wide Grep |
| `gd` / `gr` | Go to Definition / References |
| `K` | Hover Documentation |
| `s` / `S` | Leap Motion (Normal/Window) |
| `ys` / `ds` | Mini.surround (Add/Delete) |
| `:Q` | Forced Write-All and Quit |

## 📜 License

Distributed under the **GPLv3 or later** License. See `LICENSE` for more information.

