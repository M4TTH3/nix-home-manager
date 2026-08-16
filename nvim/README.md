# Neovim Configuration

## Prerequisites

### Required

- **Neovim** >= 0.12.0
- **tree-sitter CLI** — required by nvim-treesitter to compile parsers
  ```sh
  npm install -g tree-sitter-cli
  ```
  Note: `brew install tree-sitter` only installs the C library, not the CLI. Use npm or `cargo install tree-sitter-cli`.
- **Node.js** — required by some LSP servers and tools
- **Git** — required by lazy.nvim plugin manager

### Linters (nvim-lint)

```sh
# Python
brew install ruff

# Go
brew install golangci-lint

# JavaScript/TypeScript
npm install -g eslint_d
```

### Formatters (conform.nvim)

```sh
# Lua
brew install stylua

# JavaScript/TypeScript/Markdown
npm install -g prettier

# Python (uses ruff, installed above)

# Go (goimports + gofmt ship with Go)
brew install go

# Java
brew install google-java-format

# Kotlin
brew install ktfmt
```

### LSP Servers

LSP servers are installed by **Nix** (home-manager `home.packages`), not Mason. They land on `$PATH` in the Nix profile; nvim-lspconfig supplies each server's default config and `vim.lsp.enable` starts them. To add a server: add its package in `home.nix`, then list its lspconfig name in `lua/plugins/lsp.lua`.

## Setup

1. Clone this repo:
   ```sh
   git clone git@github.com:M4TTH3/nvim-config.git ~/.config/nvim
   ```

2. Open Neovim — lazy.nvim will bootstrap and install all plugins automatically.

3. Run `:Lazy` to verify all plugins are installed.

4. Parsers will auto-compile on first open (requires `tree-sitter` CLI).

## Key Bindings

See the full cheatsheet: `<Space><Space>?` or `:Cheatsheet`

### Quick Reference

| Key | Action |
|-----|--------|
| `<Space><Space>f` | Find files |
| `<Space><Space>g` | Live grep |
| `<Space>/` | Toggle floating terminal |
| `<Space>gg` | Lazygit |
| `<Space>ha` | Harpoon add file |
| `<C-1>` to `<C-4>` | Jump to harpoon file 1-4 |
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<Space>L` | Format buffer |

## Plugin Overview

| Category | Plugin |
|----------|--------|
| Theme | darcula-dark.nvim |
| File picker | snacks.nvim (picker) |
| File explorer | snacks.nvim (explorer) |
| Completion | blink.cmp + LuaSnip |
| LSP | Nix (home.packages) + nvim-lspconfig |
| Linting | nvim-lint |
| Formatting | conform.nvim |
| Git | gitsigns.nvim + lazygit |
| Diff | diffview.nvim |
| Testing | neotest (Python, Go) |
| Debugging | nvim-dap (Python, Go) |
| Navigation | harpoon, flash.nvim |
| Folding | nvim-ufo |
| Markdown | render-markdown.nvim |
| Statusline | lualine.nvim |
| Diagnostics | trouble.nvim |
| UI | noice.nvim, which-key.nvim |
