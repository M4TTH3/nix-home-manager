return {
	"coder/claudecode.nvim",
	dependencies = {
		"folke/snacks.nvim",
	},
	opts = {
		terminal = {
			provider = "snacks",
			split_side = "left",
		},
	},
	keys = {
		{ "<leader>ic", "<cmd>ClaudeCodeOpen<cr>", desc = "Open Claude Code" },
		{ "<leader>is", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
	},
}
