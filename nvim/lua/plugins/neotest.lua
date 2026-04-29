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
				-- Extra arguments for nvim-dap configuration
				-- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
				dap = { justMyCode = false },
				-- Command line arguments for runner
				-- Can also be a function to return dynamic values
				args = { "--log-level", "DEBUG" },
				-- Runner to use. Will use pytest if available by default.
				-- Can be a function to return dynamic value.
				runner = "pytest",
				-- Custom python path for the runner.
				-- Can be a string or a list of strings.
				-- Can also be a function to return dynamic value.
				-- If not provided, the path will be inferred by checking for
				-- virtual envs in the local directory and for Pipenev/Poetry configs
				python = vim.fn.filereadable(".venv/bin/python") == 1 and ".venv/bin/python" or vim.fn.exepath("python3"),
				-- Returns if a given file path is a test file.
				-- NB: This function is called a lot so don't perform any heavy tasks within it.
				-- is_test_file = function(file_path)
				-- 	local name = vim.fn.fnamemodify(file_path, ":t")
				-- 	if name:match("^test_.*%.py$") or name:match(".*_test%.py$") then
				-- 		return true
				-- 	end
				-- 	return false
				-- end,
				-- !!EXPERIMENTAL!! Enable shelling out to `pytest` to discover test
				-- instances for files containing a parametrize mark (default: false)
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
