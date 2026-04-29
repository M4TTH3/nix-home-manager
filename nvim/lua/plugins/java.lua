return {
	"mfussenegger/nvim-jdtls",
	dependencies = {
		"mason-org/mason.nvim",
		"mfussenegger/nvim-dap",
	},
	ft = "java",
	config = function()
		local mason_registry = require("mason-registry")

		if not mason_registry.is_installed then
			mason_registry.refresh()
		end

		local function get_mason_path(pkg_name)
			local ok, pkg = pcall(mason_registry.get_package, pkg_name)
			if not ok then return nil end
			local installed, path = pcall(pkg.get_install_path, pkg)
			if not installed or not path or not vim.fn.isdirectory(path) then
				pcall(pkg.install, pkg)
				return nil
			end
			return path
		end

		-- Resolve paths for Mason-installed packages (jdtls installed via mason-lspconfig)
		local jdtls_path = get_mason_path("jdtls")
		if not jdtls_path then
			vim.notify("jdtls installing via Mason — reopen a Java file when done", vim.log.levels.INFO)
			return
		end

		-- Collect debug/test extension bundles (optional — debug/test work only if installed)
		local bundles = {}
		local debug_adapter_path = get_mason_path("java-debug-adapter")
		if debug_adapter_path then
			vim.list_extend(bundles, vim.split(vim.fn.glob(debug_adapter_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n"))
		end
		local java_test_path = get_mason_path("java-test")
		if java_test_path then
			vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n"))
		end

		local function setup_jdtls()
			local jdtls = require("jdtls")
			local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
			local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

			local config = {
				cmd = {
					jdtls_path .. "/bin/jdtls",
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
