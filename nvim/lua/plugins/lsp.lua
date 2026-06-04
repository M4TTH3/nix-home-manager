return {
	"mason-org/mason-lspconfig.nvim",
	lazy = false,
	opts = {
		ensure_installed = {
			"lua_ls",
			"pyright",
			"ts_ls",
			"gopls",
			"bashls",
			"jsonls",
			"kotlin_lsp",
			"jdtls",
			"clangd",
			"rust_analyzer",
			"yamlls",
			"dockerls",
			"docker_compose_language_service",
			"html",
			"cssls",
			"tailwindcss",
			-- eslint removed: using eslint_d via nvim-lint instead
		},
	},
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
	config = function(_, opts)
		require("mason-lspconfig").setup(opts)

		-- Global capabilities from blink.cmp for all servers
		vim.lsp.config("*", {
			capabilities = require("blink.cmp").get_lsp_capabilities(),
		})

		-- Server-specific configs
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
				},
			},
		})

		vim.lsp.config("gopls", {
			settings = {
				gopls = {
					staticcheck = true,
					usePlaceholders = true,
				},
			},
		})

		vim.lsp.config("rust_analyzer", {
			settings = {
				["rust-analyzer"] = {
					completion = {
						autoimport = { enable = true },
						callable = { snippets = "fill_arguments" },
					},
					cargo = { allFeatures = true },
					checkOnSave = true,
					inlayHints = {
						bindingModeHints = { enable = false },
						closureReturnTypeHints = { enable = "with_block" },
						parameterHints = { enable = true },
						typeHints = { enable = true },
					},
				},
			},
		})

		-- Enable all servers
		vim.lsp.enable({
			"lua_ls", "pyright", "ts_ls", "gopls", "bashls", "jsonls",
			"kotlin_lsp", "clangd", "rust_analyzer", "yamlls", "dockerls",
			"docker_compose_language_service", "html", "cssls", "tailwindcss",
		})

		-- LSP keymaps on attach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
				end

				map("gd", vim.lsp.buf.definition, "Go to definition")
				map("gD", vim.lsp.buf.declaration, "Go to declaration")
				map("gr", vim.lsp.buf.references, "Find references")
				map("gi", vim.lsp.buf.implementation, "Go to implementation")
				map("gy", vim.lsp.buf.type_definition, "Go to type definition")
				map("K", vim.lsp.buf.hover, "Hover documentation")
				map("<leader>ca", vim.lsp.buf.code_action, "Code action")
				map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
				map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")

				-- Inlay hints (type/parameter annotations shown inline)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client:supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
					end, "Toggle inlay hints")
				end
				map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
				map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
			end,
		})

		vim.diagnostic.config({
			virtual_text = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				border = "rounded",
				source = true,
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
				numhl = {
					[vim.diagnostic.severity.ERROR] = "ErrorMsg",
					[vim.diagnostic.severity.WARN] = "WarningMsg",
				},
			},
		})
	end,
}
