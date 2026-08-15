return {
	"saghen/blink.cmp",
	version = "1.*",
	lazy = false,
	dependencies = {
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets",
	},
	config = function()
		require("luasnip.loaders.from_vscode").lazy_load()
		require("blink.cmp").setup({
			snippets = { preset = "luasnip" },
			keymap = { preset = "default" }, -- C-space open, C-y accept, C-n/C-p, C-e cancel
			signature = { enabled = true }, -- function signature popup while typing args
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = true }, -- inline preview of the top item
				menu = { auto_show = true },
				list = { selection = { preselect = true, auto_insert = false } },
			},
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
				},
			},
		})
	end,
}
