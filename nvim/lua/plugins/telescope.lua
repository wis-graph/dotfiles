-- local map = require("utils.keyMapper").map
--
-- return {
-- 	{
-- 		"nvim-telescope/telescope.nvim",
-- 		tag = "0.1.6",
-- 		dependencies = { "nvim-lua/plenary.nvim" },
-- 		config = function()
-- 			local telescope = require("telescope")
-- 			telescope.setup({
-- 				defaults = {
-- 					file_ignore_patterns = { "node_modules", "src-tauri" },
-- 					find_command = {
-- 						"rg",
-- 						"--files",
-- 						"--glob",
-- 						"!node_modules/**",
-- 						"--glob",
-- 						"!src-tauri/**",
-- 					},
-- 					vimgrep_arguments = {
-- 						"rg",
-- 						"--color=never",
-- 						"--no-heading",
-- 						"--with-filename",
-- 						"--line-number",
-- 						"--column",
-- 						"--smart-case",
-- 						"--glob=!node_modules/**",
-- 						"--glob=!src-tauri/**",
-- 					},
-- 				},
-- 			})
-- 			-- local builtin = require("telescope.builtin")
-- 			-- local wk = require("which-key")
-- 			-- wk.add({
-- 			-- 	{ "<leader>s", group = "search & split" },
-- 			-- 	{ "<leader>sf", builtin.find_files, desc = "search file" },
-- 			-- 	{ "<leader>st", builtin.live_grep, desc = "search text" },
-- 			-- 	{ "<leader>sb", builtin.buffers, desc = "search buffer" },
-- 			-- })
-- 			-- map("<leader>hf", builtin.help_tags) -- help function
-- 			-- map("<leader>hk", builtin.keymaps) -- help keymap
-- 		end,
-- 	},
-- 	{
-- 		"nvim-telescope/telescope-ui-select.nvim",
-- 		config = function()
-- 			-- This is your opts table
-- 			require("telescope").setup({
-- 				extensions = {
-- 					["ui-select"] = {
-- 						require("telescope.themes").get_dropdown({}),
-- 					},
-- 				},
-- 			})
-- 			require("telescope").load_extension("ui-select")
-- 		end,
-- 	},
-- }

-- plugins/telescope.lua
local map = require("utils.keyMapper").map

return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",  -- tag = "0.1.6" 대신 master 브랜치로 변경: ft_to_lang 오류 수정됨 [web:1]
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					preview = {
						treesitter = false,  -- Treesitter highlighter 임시 비활성화: nil 오류 방지 [web:1]
					},
					file_ignore_patterns = { "node_modules", "src-tauri" },
					find_command = {
						"rg",
						"--files",
						"--glob",
						"!node_modules/**",
						"--glob",
						"!src-tauri/**",
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--glob=!node_modules/**",
						"--glob=!src-tauri/**",
					},
				},
			})
			-- 기존 주석 부분 생략 (필요시 활성화)
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
