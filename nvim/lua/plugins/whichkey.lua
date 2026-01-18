return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {},
	config = function()
		local v = vim
		local wk = require("which-key")
		local M = require("config.module_fn")

		wk.add({
			-- for zig lang
			{ "<leader>z", group = "zig", buffer = true },
			{ "<leader>zb", ":!zig build<CR>", desc = "Build", buffer = true },
			{ "<leader>zr", ":!zig build run<CR>", desc = "Run", buffer = true },
			{ "<leader>zt", ":!zig build test<CR>", desc = "Test", buffer = true },
			{ "<leader>zc", ":!zig build check<CR>", desc = "Check", buffer = true },

			-- basic
			{ "<Leader>w", ":w<CR>", desc = "save" },
			{ "<Leader>1", ":q<CR>", desc = "quit" },
			{ "<Leader>q", ":bd<CR>", desc = "remove buffer" },
			{ "<Leader>e", ":Neotree toggle<CR>", desc = "toggle Neotree" },
			{ "<Leader><Tab>", ":Neotree buffers toggle<CR>", desc = "toggle Neotree buffers" },

			-- runc group
			{ "<Leader>r", group = "runners" },
			{ "<Leader>rc", ":!pwd<CR>", desc = "current path" },
			-- { "<Leader>rf", ":lua RunFile()<CR>", desc = "run python, bun, rust" },
			{
				"<Leader>rf",
				M.run_file,
				desc = "run : python, bun, rust",
			},
			{
				"<Leader>rb",
				M.build_package,
				desc = "build : npm, yarn, pnpm",
			},
			-- macro
			{
				"<Leader>mc",
				M.macro_consoleLog,
				desc = "console.log(&1^)",
			},
			-- terminal
			{ "<leader>t", group = "terminal & theme" },
			{
				"<Leader>tw",
				function()
					v.opt_local.wrap = not v.opt_local.wrap:get()
					local status = v.opt_local.wrap:get() and "ON" or "OFF"
					v.notify("Line Wrap: " .. status, v.log.levels.INFO, { title = "UI Option" })
				end,
				desc = "toggle line wrap",
			},
			{ "<leader>tf", ":ToggleTerm direction=float<CR>", desc = "f term" },
			{ "<leader>tv", ":ToggleTerm direction=horizontal<CR>", desc = "h term" },
			{ "<leader>ts", ":ToggleTerm direction=vertical<CR>", desc = "v term" },
			{ "<leader>tt", ":Themery<CR>", desc = "themery" },
			{ "<C-\\>", "<Esc>:ToggleTerm<CR>", desc = "ToggleTerm" },
			{ "<C-\\>", "<C-\\><C-n>:ToggleTerm<CR>", desc = "ToggleTerm", mode = "t" },
			{ "<C-q>", "<C-\\><C-n>", desc = "term focus out", mode = "t" },

			{ "<leader>h", group = "help" },
			{ "<leader>hf", ":Telescope help_tags<CR>", desc = "help tags" },
			{ "<leader>hk", ":Telescope keymaps<CR>", desc = "help keymaps" },

			-- search & split
			-- sf search file -- telescope
			{ "<leader>s", group = "search & split" },
			{ "<leader>sf", ":Telescope find_files<CR>", desc = "search file" },
			{ "<leader>st", ":Telescope live_grep<CR>", desc = "search text" },
			{ "<leader>sb", ":Telescope buffers", desc = "search buffer" },
			{ "<Leader>sh", ":sp<CR>", desc = "split horizontal" },
			{ "<Leader>sv", ":vsp<CR>", desc = "split vertical" },
			{ "<Leader>sm", ":Maximize<CR>", desc = "split window toggle maximize" },
			{ "<Leader>;", ":Maximize<CR>", desc = "split window toggle maximize" },

			-- parser
			{ "<leader>p", group = "parser" },
			{ "<Leader>pt", ":InspectTree<CR>", desc = "parser tree" },
			{ "<Leader>pq", ":EditQuery<CR>", desc = "parser query" },
			{
				"<Leader>pm",
				function()
					local abs_path = v.fn.expand("%:p")
					M.markdown_copy(abs_path)
				end,
				desc = "Markdown Copy",
			},

			-- undo tree
			{ "<Leader>u", ":UndotreeToggle<CR>", desc = "toggle undo tree" },

      -- git
			{ "<leader>g", group = "git" },
			{ "<Leader>gg", ":Neotree git_status<CR>", desc = "toggle git status" },
      {
        "<leader>gl",
        function()
          require("gitgraph").draw({}, { all = true, max_count = 5000 })
        end,
        desc = "GitGraph - Draw",
      },
		})
	end,
	keys = {},
}
