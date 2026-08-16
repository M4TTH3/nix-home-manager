return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- adapters
		"nvim-neotest/neotest-python",
		"fredrikaverpil/neotest-golang",
		"rcasia/neotest-java",
	},
	config = function()
		local default_config = require("neotest.config")
		default_config.adapters = {
			require("neotest-python")({
				dap = { justMyCode = false },
				args = { "--log-level", "DEBUG" },
				runner = "pytest",
				python = vim.fn.filereadable(".venv/bin/python") == 1 and ".venv/bin/python" or vim.fn.exepath("python3"),
				-- shell out to pytest so parametrized tests are discovered
				pytest_discover_instances = true,
			}),
			require("neotest-golang")({}),
			require("neotest-java")({
				java_home = vim.fn.expand("$JAVA_HOME"),
			}),
		}

		require("neotest").setup(default_config)
	end,
	keys = {
		{ "<leader><leader>t", "<cmd>Neotest summary<cr>",                                    desc = "Toggle summary window" },
		{ "<leader>tr",        "<cmd>Neotest run<cr>",                                        desc = "Run current test" },
		{ "<leader>tl",        "<cmd>Neotest run last<cr>",                                   desc = "Run last test" },
		{ "<leader>tf",        "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "Run test file" },
		{ "<leader>ts",        "<cmd>Neotest stop<cr>",                                       desc = "Stop current test" },
		{ "<leader>tp",        "<cmd>Neotest output-panel<cr>",                               desc = "Toggle output panel" },
		{ "<leader>tc",        "<cmd>Neotest output-panel clear<cr>",                         desc = "Clear output panel" },
		{ "<leader>to",        "<cmd>Neotest output<cr>",                                     desc = "Open test output" },
		{ "<leader>tw",        "<cmd>lua require('neotest').watch.toggle()<cr>",              desc = "Toggle watch" },
		{ "<leader>td",        "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",  desc = "Debug current test" },
		{ "<leader>ta",        "<cmd>Neotest attach<cr>",                                     desc = "Attach to current test" },
	},
}
