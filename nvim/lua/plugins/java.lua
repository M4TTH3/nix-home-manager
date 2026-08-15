return {
	"mfussenegger/nvim-jdtls",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	ft = "java",
	config = function()
		-- jdtls + debug/test bundles come from Nix (home.nix), not Mason:
		--   jdtls binary -> on PATH (jdt-language-server)
		--   bundles      -> JDTLS_DEBUG_DIR / JDTLS_TEST_DIR env vars
		-- Collect debug/test bundles (optional — debug/test work only if present).
		local bundles = {}
		local debug_dir = vim.env.JDTLS_DEBUG_DIR
		if debug_dir and vim.fn.isdirectory(debug_dir) == 1 then
			vim.list_extend(bundles, vim.split(vim.fn.glob(debug_dir .. "/com.microsoft.java.debug.plugin-*.jar"), "\n", { trimempty = true }))
		end
		local test_dir = vim.env.JDTLS_TEST_DIR
		if test_dir and vim.fn.isdirectory(test_dir) == 1 then
			vim.list_extend(bundles, vim.split(vim.fn.glob(test_dir .. "/*.jar"), "\n", { trimempty = true }))
		end

		local function setup_jdtls()
			local jdtls = require("jdtls")
			local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
			local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

			local config = {
				cmd = {
					"jdtls", -- from Nix (jdt-language-server) on PATH
					"-data", workspace_dir,
				},
				root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
				capabilities = require("blink.cmp").get_lsp_capabilities(),
				settings = {
					java = {
						signatureHelp = { enabled = true },
						contentProvider = { preferred = "fernflower" },
						completion = {
							favoriteStaticMembers = {
								"org.junit.Assert.*",
								"org.junit.jupiter.api.Assertions.*",
								"org.mockito.Mockito.*",
							},
						},
						sources = {
							organizeImports = {
								starThreshold = 9999,
								staticStarThreshold = 9999,
							},
						},
					},
				},
				init_options = {
					bundles = bundles,
				},
				on_attach = function(_, bufnr)
					jdtls.setup_dap({ hotcodereplace = "auto" })

					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Java: " .. desc })
					end

					map("<leader>jo", jdtls.organize_imports, "Organize imports")
					map("<leader>jv", jdtls.extract_variable, "Extract variable")
					map("<leader>jm", jdtls.extract_method, "Extract method")
					map("<leader>jt", jdtls.test_nearest_method, "Run nearest test")
					map("<leader>jT", jdtls.test_class, "Run test class")
				end,
			}

			jdtls.start_or_attach(config)
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = setup_jdtls,
		})
	end,
}
