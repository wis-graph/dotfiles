local map = require("utils.keyMapper").map
return {
	-- {
	-- 	"williamboman/mason.nvim",
	-- 	config = function()
	-- 		require("mason").setup()
	-- 	end,
	-- },
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
				"ts_ls",
				"html",
				"jsonls",
				"markdown_oxide",
				"pyright",
				-- "rust_analyzer",
				"svelte",
				"taplo",
				"tailwindcss",
				-- "clojure_lsp",
				-- "zls",
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			local wk = require("which-key")
			local M = require("config.module_fn")
			local v = vim
			-- LSP가 연결된 후에 인레이 힌트를 활성화하는 자동 명령 설정
			v.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = v.lsp.get_client_by_id(args.data.client_id)
					-- if client.server_capabilities.inlayHintProvider then
					-- 	v.lsp.inlay_hint.enable(true)
					-- end
				end,
			})
			-- lspconfig.zls.setup({
			-- 	settings = {
			-- 		zls = {
			-- 			enable_autofix = true,
			-- 			enable_snippets = true,
			-- 			enable_ast_check_diagnostics = true,
			-- 			enable_build_on_save = false, -- 수동으로 빌드하는 게 나음
			-- 			warn_style = true,
			-- 		},
			-- 	},
			-- })
			lspconfig.pyright.setup({
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
						},
					},
				},
			})
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						hint = {
							enable = true, -- necessary
						},
					},
				},
			})
			lspconfig.html.setup({})
			lspconfig.jsonls.setup({})
			lspconfig.markdown_oxide.setup({})
			-- lspconfig.rust_analyzer.setup({
			-- 	settings = {
			-- 		["rust-analyzer"] = {
			-- 			cargo = {
			-- 				allFeatures = true,
			-- 			},
			-- 			inlayHints = {
			-- 				-- bindingModeHints = {
			-- 				-- 	enable = false,
			-- 				-- },
			-- 				-- chainingHints = {
			-- 				-- 	enable = true,
			-- 				-- },
			-- 				-- closingBraceHints = {
			-- 				-- 	enable = true,
			-- 				-- 	minLines = 25,
			-- 				-- },
			-- 				-- closureReturnTypeHints = {
			-- 				-- 	enable = "never",
			-- 				-- },
			-- 				-- lifetimeElisionHints = {
			-- 				-- 	enable = "never",
			-- 				-- 	useParameterNames = false,
			-- 				-- },
			-- 				-- maxLength = 25,
			-- 				-- parameterHints = {
			-- 				-- 	enable = true,
			-- 				-- },
			-- 				-- reborrowHints = {
			-- 				-- 	enable = "never",
			-- 				-- },
			-- 				-- renderColons = true,
			-- 				-- typeHints = {
			-- 				-- 	enable = true,
			-- 				-- 	hideClosureInitialization = false,
			-- 				-- 	hideNamedConstructor = false,
			-- 				-- },
			-- 			},
			-- 			procMacro = {
			-- 				enable = true,
			-- 				ignored = {
			-- 					leptos_macro = {
			-- 						"component",
			-- 						"server",
			-- 					},
			-- 				},
			-- 			},
			-- 		},
			-- 	},
			-- })
			lspconfig.taplo.setup({})
			lspconfig.tailwindcss.setup({})
			lspconfig.ts_ls.setup({
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = true,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = true,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
			})
			-- lspconfig.clojure_lsp.setup({})
			lspconfig.svelte.setup({
				settings = {
					typescript = {
						-- inlayHints = {
						-- 	parameterNames = { enabled = "all" },
						-- 	parameterTypes = { enabled = true },
						-- 	variableTypes = { enabled = true },
						-- 	propertyDeclarationTypes = { enabled = true },
						-- 	functionLikeReturnTypes = { enabled = true },
						-- 	enumMemberValues = { enabled = true },
						-- },
					},
				},
			})

			map("K", "<cmd>lua vim.lsp.buf.hover()<CR>")
			map("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
			wk.add({
				{ "<leader>l", group = "language service" },
				{ "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "code Action" },
				{ "<leader>ld", v.diagnostic.setqflist, desc = "Diagnostic" },
				{ "<leader>lr", ":LspRestart<CR>", desc = "lsp Restart" },
				-- { "<leader>lh", M.toggle_inlay_hint, desc = "inlay Hint" },
				-- { "<leader>lv", ":Vista nvim_lsp<CR>", desc = "lsp tree" },
				{ "<leader>lo", "<cmd>Outline<CR>", desc = "Outline" },
				{ "<leader>lu", ":UndotreeToggle<CR>", desc = "Undo tree" },
				{ "<leader>ln", ":cnext<CR>", desc = "Next Diagnostics" },
				{ "g", group = "go to" },
				{ "gl", v.diagnostic.open_float, desc = "open diagnostic float" },
				{ "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "go to definition" },
				{
					"gs",
					function()
						v.cmd([[split]])
						v.cmd([[wincmd j]])
						v.lsp.buf.definition()
					end,
					desc = "open definition vertical",
				},
				{
					"gv",
					function()
						v.cmd([[vsplit]])
						v.cmd([[wincmd l]])
						v.lsp.buf.definition()
					end,
					desc = "open definition vertical",
				},
			})
		end,
	},
}

