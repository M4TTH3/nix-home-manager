return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- File picker (replaces telescope)
		picker = {
			enabled = true,
			sources = {
				explorer = {
					layout = {
						layout = {
							position = "right",
						},
					},
				},
			},
		},
		-- File explorer (replaces nvim-tree)
		explorer = {
			enabled = true,
		},
		-- Floating terminal (persistent -- toggles in/out keeping your session)
		terminal = {
			enabled = true,
			win = {
				style = "float",
				border = "rounded",
				width = 0.85,
				height = 0.75,
				backdrop = 60,
				title = " Terminal ",
				title_pos = "center",
				footer = " q: close | <Space>/: toggle | <Space>jh: split ",
				footer_pos = "center",
				bo = {
					filetype = "snacks_terminal",
				},
			},
		},
		-- Lazygit integration
		lazygit = {
			enabled = true,
		},
		-- Dashboard disabled
		dashboard = {
			enabled = false,
		},
		-- Indent guides
		indent = {
			enabled = true,
			animate = { enabled = false },
		},
		-- Notifications
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		-- Highlight word under cursor
		words = {
			enabled = true,
		},
		-- Performance on big files
		bigfile = {
			enabled = true,
			size = 1.5 * 1024 * 1024, -- 1.5MB
		},
		-- Smooth scrolling
		scroll = {
			enabled = true,
			animate = { duration = { step = 15, total = 150 } },
		},
		-- Status column
		statuscolumn = {
			enabled = true,
		},
	},
	keys = {
		-- Picker (replacing telescope keybinds)
		{ "<leader><leader>f", function() Snacks.picker.files() end, desc = "Find files" },
		{ "<leader><leader>g", function() Snacks.picker.grep() end, desc = "Live grep" },
		{ "<leader><leader>b", function() Snacks.picker.buffers() end, desc = "Buffers" },
		{ "<leader><leader>h", function() Snacks.picker.help() end, desc = "Help tags" },
		{ "<leader><leader>r", function() Snacks.picker.resume() end, desc = "Resume last picker" },
		{ "<leader><leader>d", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
		{ "<leader><leader>c", function() Snacks.picker.commands() end, desc = "Commands" },
		{ "<leader><leader>k", function() Snacks.picker.keymaps() end, desc = "Search keybindings" },
		{ "<leader>ds", function() Snacks.picker.lsp_symbols() end, desc = "Document symbols" },
		{ "<leader>ws", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols" },
		-- Explorer (replacing nvim-tree)
		{ "<leader><leader>w", function() Snacks.explorer() end, desc = "File explorer" },
		-- Git
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
		{ "<leader>gl", function() Snacks.lazygit.log() end, desc = "Git log" },
		{ "<leader>gF", function() Snacks.lazygit.log_file() end, desc = "Git file log (lazygit)" },
		-- Terminal (floating toggle -- persistent session)
		{ "<leader>/", function() Snacks.terminal() end, desc = "Toggle floating terminal" },
		-- Terminal (pinned as split)
		{ "<leader>jh", function() Snacks.terminal(nil, { win = { style = "split", position = "bottom", height = 0.3, border = "top" } }) end, desc = "Terminal (bottom split)" },
		{ "<leader>jv", function() Snacks.terminal(nil, { win = { style = "split", position = "right", width = 0.4, border = "left" } }) end, desc = "Terminal (right split)" },
		-- Notifications
		{ "<leader>un", function() Snacks.notifier.show_history() end, desc = "Notification history" },
		{ "<leader>ud", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
	},
}
