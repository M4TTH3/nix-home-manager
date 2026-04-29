return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			"mfussenegger/nvim-dap-python",
			"leoluz/nvim-dap-go",
		},
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
			{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
			{ "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
			{ "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
			{ "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
			{ "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
			{ "<leader>dx", function() require("dap").terminate() end, desc = "Terminate" },
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- DAP UI setup
			dapui.setup()
			require("nvim-dap-virtual-text").setup()

			-- Auto open/close DAP UI
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Python adapter (uses debugpy)
			local python_path = vim.fn.filereadable(".venv/bin/python") == 1 and ".venv/bin/python" or vim.fn.exepath("python3")
			require("dap-python").setup(python_path)

			-- Go adapter (uses delve)
			require("dap-go").setup()
		end,
	},
}
