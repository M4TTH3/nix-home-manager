return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
	config = function(_, opts)
		local wk = require("which-key")

		wk.setup(opts)
		wk.add({
			{ "<leader>w", proxy = "<c-w>", group = "windows" },
			{ "<leader>t", group = "test" },
			{ "<leader>d", group = "debug" },
			{ "<leader>h", group = "git hunks" },
			{ "<leader>x", group = "diagnostics" },
			{ "<leader>c", group = "code" },
			{ "<leader>i", group = "AI" },
			{ "<leader>g", group = "git" },
			{ "<leader>s", group = "search" },
			{ "<leader>j", group = "terminal" },
			{ "<leader>q", group = "quit" },
			{ "<leader>u", group = "ui" },
			{ "<leader>r", group = "refactor" },
			{ "<leader>b", group = "buffer" },
			{ "<leader><leader>", group = "major" },
		})

		-- which-key v3 loses its per-buffer leader trigger when pickers/macros
		-- remap <Space> (folke/which-key.nvim#783, #4841), killing the popup
		-- mid-session. Force a re-attach on the events where triggers get lost.
		local heal = vim.api.nvim_create_augroup("wk_reattach", { clear = true })
		vim.api.nvim_create_autocmd({ "BufWinEnter", "RecordingLeave", "WinClosed" }, {
			group = heal,
			callback = function(ev)
				vim.schedule(function()
					pcall(function()
						require("which-key.buf").get({ buf = ev.buf, update = true })
					end)
				end)
			end,
		})
	end,
}
