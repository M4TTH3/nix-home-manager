return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewFileHistory" },
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff view" },
		{ "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
	},
	opts = {},
}
