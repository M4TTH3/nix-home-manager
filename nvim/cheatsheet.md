# Neovim Keybinding Cheatsheet

Leader key: `<Space>`

## Search & Navigation (snacks picker)

| Key               | Action              |
|-------------------|---------------------|
| `<Space><Space>f` | Find files          |
| `<Space><Space>g` | Live grep           |
| `<Space><Space>b` | Buffers             |
| `<Space><Space>h` | Help tags           |
| `<Space><Space>r` | Resume last picker  |
| `<Space><Space>d` | Diagnostics picker  |
| `<Space><Space>c` | Command palette     |
| `<Space><Space>k` | Search keybindings  |
| `<Space><Space>w` | File explorer       |

## LSP

| Key          | Action              |
|--------------|---------------------|
| `gd`         | Go to definition    |
| `gD`         | Go to declaration   |
| `gr`         | Find references     |
| `gi`         | Go to implementation|
| `gy`         | Go to type def      |
| `K`          | Hover documentation |
| `<Space>ca`  | Code action         |
| `<Space>rn`  | Rename symbol       |
| `<Space>cd`  | Line diagnostics    |
| `[d` / `]d`  | Prev/next diagnostic|
| `<Space>ds`  | Document symbols    |
| `<Space>ws`  | Workspace symbols   |

## Git

| Key          | Action              |
|--------------|---------------------|
| `<Space>gg`  | Lazygit             |
| `<Space>gl`  | Git log             |
| `<Space>gf`  | File history (diffview) |
| `<Space>gd`  | Diff view           |
| `<Space>gF`  | Git file log (lazygit)  |
| `]h` / `[h`  | Next/prev hunk      |
| `<Space>hs`  | Stage hunk          |
| `<Space>hr`  | Reset hunk          |
| `<Space>hS`  | Stage buffer        |
| `<Space>hR`  | Reset buffer        |
| `<Space>hp`  | Preview hunk        |
| `<Space>hb`  | Blame line          |
| `<Space>hd`  | Diff this           |

## Debugging (DAP)

| Key          | Action              |
|--------------|---------------------|
| `<Space>db`  | Toggle breakpoint   |
| `<Space>dB`  | Conditional breakpt |
| `<Space>dc`  | Continue            |
| `<Space>di`  | Step into           |
| `<Space>do`  | Step over           |
| `<Space>dO`  | Step out            |
| `<Space>dr`  | Toggle REPL         |
| `<Space>dl`  | Run last            |
| `<Space>du`  | Toggle DAP UI       |
| `<Space>dx`  | Terminate           |

## Diagnostics (Trouble)

| Key          | Action              |
|--------------|---------------------|
| `<Space>xx`  | All diagnostics     |
| `<Space>xX`  | Buffer diagnostics  |
| `<Space>cs`  | Symbols outline     |
| `<Space>cl`  | LSP refs/defs       |
| `<Space>xL`  | Location list       |
| `<Space>xQ`  | Quickfix list       |

## AI

| Key          | Action              |
|--------------|---------------------|
| `<Space>ic`  | Open Claude Code    |
| `<Space>is`  | Send to Claude (v)  |

## Quick Navigation (Flash)

| Key  | Mode      | Action              |
|------|-----------|---------------------|
| `s`  | n, x, o   | Flash jump          |
| `S`  | n, x, o   | Flash treesitter    |
| `r`  | o         | Remote flash        |
| `R`  | o, x      | Treesitter search   |

## Treesitter Text Objects

| Key          | Action              |
|--------------|---------------------|
| `af` / `if`  | Function outer/inner|
| `ac` / `ic`  | Class outer/inner   |
| `ai` / `ii`  | If-stmt outer/inner |
| `al` / `il`  | Loop outer/inner    |
| `ap` / `ip`  | Parameter out/inner |
| `[f` / `]f`  | Prev/next function  |
| `[c` / `]c`  | Prev/next class     |
| `[p` / `]p`  | Prev/next parameter |
| `<Space>a`   | Swap next param     |
| `<Space>A`   | Swap prev param     |
| `<Space>vv`  | Init selection      |
| `+` / `_`    | Expand/shrink sel   |

## TODO Comments

| Key          | Action              |
|--------------|---------------------|
| `]t` / `[t`  | Next/prev TODO      |
| `<Space>st`  | Search all TODOs    |

## General

| Key          | Action              |
|--------------|---------------------|
| `<C-s>`      | Save file           |
| `<Esc>`      | Clear search hl     |
| `<A-j/k>`    | Move line down/up   |
| `<C-h/j/k/l>`| Window navigation  |
| `<Space>qq`  | Quit all            |
| `<Space>?`   | Show all keymaps    |
| `<Space><Space>?` | This cheatsheet|
| `<Space>L`   | Format buffer       |

## Terminal

| Key          | Action              |
|--------------|---------------------|
| `<Space>/`   | Toggle floating terminal          |
| `<Space>jh`  | Pin terminal bottom split         |
| `<Space>jv`  | Pin terminal right split          |
| `<Esc><Esc>`| Back to normal mode (in terminal) |

## Command Panel (noice.nvim)

Commands (`:`) and search (`/`) automatically appear as floating popups.
LSP hover and signature help also use floating windows.

## Surround (mini.surround)

| Key          | Action              |
|--------------|---------------------|
| `sa`         | Add surrounding     |
| `sd`         | Delete surrounding  |
| `sr`         | Replace surrounding |

## Harpoon (quick file switching)

| Key          | Action              |
|--------------|---------------------|
| `<Space>ha`  | Add file to harpoon |
| `<Space>hh`  | Harpoon menu        |
| `<C-1>`      | Jump to file 1      |
| `<C-2>`      | Jump to file 2      |
| `<C-3>`      | Jump to file 3      |
| `<C-4>`      | Jump to file 4      |

## Folding (nvim-ufo)

| Key  | Action              |
|------|---------------------|
| `zR` | Open all folds      |
| `zM` | Close all folds     |
| `zK` | Peek folded lines   |
| `za` | Toggle fold         |

## UI

| Key          | Action              |
|--------------|---------------------|
| `<Space>un`  | Notification history|
| `<Space>ud`  | Dismiss notifications|

## Testing (neotest)

| Key              | Action              |
|------------------|---------------------|
| `<Space><Space>t`| Test summary        |
| `<Space>tr`      | Run current test    |
| `<Space>tl`      | Run last test       |
| `<Space>tf`      | Run test file       |
| `<Space>ts`      | Stop test           |
| `<Space>tp`      | Toggle output panel |
| `<Space>to`      | Open test output    |
| `<Space>tw`      | Toggle watch        |
