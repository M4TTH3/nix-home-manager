return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
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
	end
}
