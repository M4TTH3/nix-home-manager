return {
	"M4TTH3/noice-llm.nvim",
	main = "noice",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
			format = {
				cmdline = { pattern = "^:", icon = " ", lang = "vim" },
				search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
				search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
				filter = { pattern = "^:%s*!", icon = " ", lang = "bash" },
				lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
			},
		},
		messages = {
			enabled = true,
			view_search = "virtualtext",
		},
		popupmenu = {
			enabled = true,
			backend = "nui",
		},
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
			hover = {
				enabled = true,
			},
			signature = {
				enabled = true,
			},
		},
		llm = {
			enabled = true,
			provider = "claude",
			model = "claude-sonnet-4-20250514",
			api_key_env = "CLAUDE_API_KEY",
		},
		presets = {
			bottom_search = false,
			command_palette = true,
			long_message_to_split = true,
			lsp_doc_border = true,
		},
	},
}
