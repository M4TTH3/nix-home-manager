return {
	"M4TTH3/darcula-dark.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("darcula").setup({
			opt = {
				integrations = {
					telescope = false,
					snacks = true,
					lualine = true,
					lsp_semantics_token = true,
					nvim_cmp = false,
					dap_nvim = true,
					noice = true,
					flash = true,
					trouble = true,
					todo_comments = true,
					which_key = true,
					mini = true,
					barbar = false,
					blink_cmp = true,
					render_markdown = true,
					diffview = true,
					ufo = true,
					harpoon = true,
				},
			},
		})
	end,
}
