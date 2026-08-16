vim.wo.number = true
vim.opt.relativenumber = true

vim.o.mouse = "a"
vim.opt.encoding = "utf-8"
vim.opt.termguicolors = true

vim.opt.scrolloff = 7
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true

vim.opt.fileformat = "unix"

-- Modern IDE settings
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

-- Reload buffers edited on disk by external tools (Claude Code, git, jj) so
-- the buffer and LSP don't go stale. FocusGained needs tmux focus-events on
-- (home.nix); CursorHold covers edits while focus never left (terminal split).
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
	group = vim.api.nvim_create_augroup("autoread_checktime", { clear = true }),
	callback = function()
		if vim.api.nvim_get_mode().mode ~= "c" and vim.bo.buftype == "" then
			vim.cmd.checktime()
		end
	end,
})

-- Notify when a buffer was reloaded from disk
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = vim.api.nvim_create_augroup("autoread_notify", { clear = true }),
	callback = function(ev)
		vim.notify("Reloaded from disk: " .. vim.fn.fnamemodify(ev.file, ":~:."), vim.log.levels.INFO)
	end,
})
