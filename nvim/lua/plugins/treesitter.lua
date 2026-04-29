return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
		},
		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			-- Auto-install parsers
			local parsers = {
				"vim", "lua", "luadoc", "python", "typescript", "javascript",
				"kotlin", "java", "go", "elixir", "sql", "json", "yaml",
				"markdown", "markdown_inline", "html", "css", "dockerfile",
				"toml", "rust", "bash", "regex", "tsx",
			}
			for _, parser in ipairs(parsers) do
				pcall(function()
					require("nvim-treesitter").install(parser)
				end)
			end

			-- Enable treesitter highlighting and indentation
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})

			-- Textobjects (main branch API)
			require("nvim-treesitter-textobjects").setup({
				select = {
					enable = true,
					lookahead = true,
				},
				move = {
					set_jumps = true,
				},
				swap = {},
			})

			local ts_select = require("nvim-treesitter-textobjects.select")
			local ts_move = require("nvim-treesitter-textobjects.move")
			local ts_swap = require("nvim-treesitter-textobjects.swap")

			-- Select keymaps
			vim.keymap.set({ "x", "o" }, "af", function() ts_select.select_textobject("@function.outer") end, { desc = "around function" })
			vim.keymap.set({ "x", "o" }, "if", function() ts_select.select_textobject("@function.inner") end, { desc = "inner function" })
			vim.keymap.set({ "x", "o" }, "ac", function() ts_select.select_textobject("@class.outer") end, { desc = "around class" })
			vim.keymap.set({ "x", "o" }, "ic", function() ts_select.select_textobject("@class.inner") end, { desc = "inner class" })
			vim.keymap.set({ "x", "o" }, "ai", function() ts_select.select_textobject("@conditional.outer") end, { desc = "around if" })
			vim.keymap.set({ "x", "o" }, "ii", function() ts_select.select_textobject("@conditional.inner") end, { desc = "inner if" })
			vim.keymap.set({ "x", "o" }, "al", function() ts_select.select_textobject("@loop.outer") end, { desc = "around loop" })
			vim.keymap.set({ "x", "o" }, "il", function() ts_select.select_textobject("@loop.inner") end, { desc = "inner loop" })
			vim.keymap.set({ "x", "o" }, "ap", function() ts_select.select_textobject("@parameter.outer") end, { desc = "around parameter" })
			vim.keymap.set({ "x", "o" }, "ip", function() ts_select.select_textobject("@parameter.inner") end, { desc = "inner parameter" })

			-- Move keymaps
			vim.keymap.set({ "n", "x", "o" }, "[f", function() ts_move.goto_previous_start("@function.outer") end, { desc = "Previous function" })
			vim.keymap.set({ "n", "x", "o" }, "]f", function() ts_move.goto_next_start("@function.outer") end, { desc = "Next function" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function() ts_move.goto_previous_start("@class.outer") end, { desc = "Previous class" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function() ts_move.goto_next_start("@class.outer") end, { desc = "Next class" })
			vim.keymap.set({ "n", "x", "o" }, "[p", function() ts_move.goto_previous_start("@parameter.inner") end, { desc = "Previous parameter" })
			vim.keymap.set({ "n", "x", "o" }, "]p", function() ts_move.goto_next_start("@parameter.inner") end, { desc = "Next parameter" })

			-- Swap keymaps
			vim.keymap.set("n", "<leader>a", function() ts_swap.swap_next("@parameter.inner") end, { desc = "Swap next param" })
			vim.keymap.set("n", "<leader>A", function() ts_swap.swap_previous("@parameter.inner") end, { desc = "Swap prev param" })
		end,
	},
}
