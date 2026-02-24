-- mermaid renderer
return {
	"3rd/diagram.nvim",
	dependencies = {
		"3rd/image.nvim",
	},
	opts = {
		events = {
			render_buffer = { "InsertLeave", "BufWinEnter", "TextChanged" },
			clear_buffer = { "BufLeave" },
		},
		renderer_options = {
			mermaid = {
				background = "white",
				theme = "default",
				scale = 2,
			},
		},
	},
	ft = { "markdown" },
}
