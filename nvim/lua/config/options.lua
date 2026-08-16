-- Leaders must be set before keymaps are defined and before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable netrw (snacks explorer replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = "a"
vim.opt.encoding = "utf-8"
vim.opt.termguicolors = true

vim.opt.scrolloff = 7
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true

vim.opt.fileformat = "unix"

vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = false
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Reload buffers edited on disk by external tools (git, jj, agents); see
-- the checktime autocmd in autocmds.lua
vim.opt.autoread = true
