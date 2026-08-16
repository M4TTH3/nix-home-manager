-- Reload buffers edited on disk by external tools (git, jj, agents) so the
-- buffer and LSP don't go stale. FocusGained needs tmux focus-events on
-- (home.nix); CursorHold covers edits while focus never left (terminal split).
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

-- Disable mini.pairs' single-quote pairing in Rust (fights lifetimes like 'a).
-- Buffer-local map here so it survives the plugin's lazy InsertEnter load.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("rust_no_quote_pair", { clear = true }),
	pattern = "rust",
	callback = function()
		vim.keymap.set("i", "'", "'", { buffer = true })
	end,
})
