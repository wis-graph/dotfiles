return {
	"3rd/image.nvim",
	event = "VeryLazy",
	-- build = false, -- for magick_cli
	dependencies = {
		{ "luarocks.nvim" },
{
      "vhyrro/luarocks.nvim",
      priority = 1001, -- 의존성 우선순위 설정
      opts = {
        rocks = { "magick" },
      },
    },
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			config = function()
				require("nvim-treesitter.configs").setup({
					ensure_installed = { "markdown" },
					highlight = { enable = true },
				})
			end,
		},
	},
	opts = {
		backend = "kitty",
		processor = "magick_rock", -- or "magick_cli" | "magick_rock"
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				floating_windows = false, -- if true, images will be rendered in floating markdown windows
				filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
				resolve_image_path = function(document_path, image_path, fallback)
					-- You can implement your custom logic for resolving image paths here
					-- document_path is the path to the markdown document
					-- image_path is the relative or full path to the image
					-- fallback is a function that provides the default behavior if needed

					-- Example: prepend document_path's directory to relative image paths
					local path = vim.fn.fnamemodify(document_path, ":h") .. "/" .. image_path
					return path
				end,
			},
			neorg = {
				enabled = false,
				filetypes = { "norg" },
			},
			typst = {
				enabled = false,
				filetypes = { "typst" },
			},
			html = {
				enabled = false,
			},
			css = {
				enabled = false,
			},
		},
		max_width = nil,
		max_height = nil,
		max_width_window_percentage = nil,
		max_height_window_percentage = 50,
		window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
		tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
		hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
	},
}
