return {
	dir = ".",
	name = "cheatsheet",
	lazy = false,
	config = function()
		vim.api.nvim_create_user_command("Cheatsheet", function()
			local path = vim.fn.stdpath("config") .. "/cheatsheet.md"
			local lines = vim.fn.readfile(path)

			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.bo[buf].filetype = "markdown"
			vim.bo[buf].bufhidden = "wipe"
			vim.bo[buf].modifiable = false

			local width = math.floor(vim.o.columns * 0.8)
			local height = math.floor(vim.o.lines * 0.8)
			local row = math.floor((vim.o.lines - height) / 2)
			local col = math.floor((vim.o.columns - width) / 2)

			vim.api.nvim_open_win(buf, true, {
				relative = "editor",
				width = width,
				height = height,
				row = row,
				col = col,
				style = "minimal",
				border = "rounded",
				title = " Cheatsheet ",
				title_pos = "center",
			})

			-- Press q or Esc to close
			vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
			vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
		end, {})

		vim.keymap.set("n", "<leader><leader>?", "<cmd>Cheatsheet<cr>", { desc = "Cheatsheet" })
	end,
}
