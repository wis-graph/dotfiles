```lua lua/config/globals.lua

local v = vim
v.g.mapleader = " "
v.g.maplocalleader = " "
v.api.nvim_set_option("clipboard", "unnamed")

```

```lua lua/config/iabbr.lua

local function set_iabbr(from, to)
	vim.cmd(string.format("iabbrev %s %s", from, to))
end

local function set_exp_iabbr(from, to)
	vim.cmd(string.format("iabbrev <expr> %s %s", from, to))
end

local function set_iabbrs(tbl)
	for from, data in pairs(tbl) do
		if type(data) == "table" then
			-- expr 옵션이 true이면 set_exp_iabbr 사용
			if data.expr then
				set_exp_iabbr(from, data.to)
			else
				set_iabbr(from, data.to)
			end
		else
			-- 단순한 축약어 처리
			set_iabbr(from, data)
		end
	end
end

set_iabbrs({
	teh = "the",
	adn = "and",
	becuase = "because",
	recieve = "receive",
	__time = { to = "strftime('(%Y-%m-%d %H:%M:%S)')", expr = true },
	__date = { to = "strftime('(%Y-%m-%d)')", expr = true },
	__file = { to = "expand('%:p')", expr = true }, -- full path
	__name = { to = "expand('%')", expr = true }, -- relative path
	__pwd = { to = "expand('%:p:h')", expr = true },
	__uuid = { to = "system('uuidgen')", expr = true },
})

```

```lua lua/config/init.lua

-- lazy install
local v = vim

-- Bootstrap lazy.nvim
local lazypath = v.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (v.uv or v.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = v.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if v.v.shell_error ~= 0 then
		v.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		v.fn.getchar()
		os.exit(1)
	end
end

v.opt.rtp:prepend(lazypath)

require("config.globals")
require("config.keymaps")
require("config.neovide")
require("config.iabbr")
require("config.options")

-- luarocks
-- package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
-- package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"

-- 플러그인 폴더의 루아 파일들을 모두 가져옴
local plugins = "plugins"
local opts = {
	rocks = {
		hererocks = false, -- recommended if you do not have global installation of Lua 5.1.
		enabled = false,
	},
}

require("lazy").setup(plugins, opts)

```

```lua lua/config/keymaps.lua

local map = require("utils.keyMapper").map
local v = vim
--map(from, to, mode="n", opts)
-- for nvim function dev
-- indent
map("<", "<gv", "v")
map(">", ">gv", "v")

-- map("<Leader>f", ":Telescope find_files<CR>", "n")
-- map("<Leader>t", ":Telescope live_grep<CR>", "n")

map("<Leader>L", ":Lazy<CR>")
map("<Leader>M", ":Mason<CR>")

-- buffer previos next
map("<Leader>b", ":bprevious<CR>")
map("<Leader>n", ":bnext<CR>")

-- pane size
map("<C-S-j>", "<C-w>-")
map("<C-S-k>", "<C-w>+")
map("<C-S-h>", "<C-w><")
map("<C-S-l>", "<C-w>>")
-- pane move
map("<C-h>", "<C-w>h")
map("<C-j>", "<C-w>j")
map("<C-k>", "<C-w>k")
map("<C-l>", "<C-w>l")

-- remove highlight
map("<Leader>/", ":nohlsearch<CR>")

-- treesitter
map("<leader>ht", ":TSModuleInfo<CR>") -- help treesitter module info -- will remove

--- ufo
-- map('zR', ufo.openAllFolds)
-- map('zM', ufo.closeAllFolds)

```

```lua lua/config/module_fn.lua

local M = {}
local v = vim
-- macros
function M.macro_consoleLog()
	v.api.nvim_feedkeys('iyeoconsole.log("', "n", true)
	v.api.nvim_feedkeys("<Esc>", "n", true)
	v.api.nvim_feedkeys("ipa:", "n", true)
	v.api.nvim_feedkeys("<Esc>", "n", true)
	v.api.nvim_feedkeys("ipa)", "n", true)
	v.api.nvim_feedkeys("<Esc>", "n", true)
end
-- for neotree
function M.copy_file_info_to_clipboard(state)
	local node = state.tree:get_node()
	local filepath = node:get_id()
	local filename = node.name
	local modify = v.fn.fnamemodify

	local results = {
		filepath,
		modify(filepath, ":."), -- Relative path to CWD
		modify(filepath, ":~"), -- Relative path to HOME
		filename,
		modify(filename, ":r"), -- Filename without extension
		modify(filename, ":e"), -- File extension
	}

	-- Show options to user and get the selection
	local i = v.fn.inputlist({
		"복사할 내용을 고르세요:",
		"1. 절대경로: " .. results[1],
		"2. 상대경로(cwd): " .. results[2],
		"3. 상대경로(~): " .. results[3],
		"4. 파일명.확장자: " .. results[4],
		"5. 파일명: " .. results[5],
		"6. 확장자: " .. results[6],
		"7. 파일 내 컨텐츠 마크다운복사",
		"8. 폴더 내 컨텐츠 마크다운복사",
		"9. 폴더 내 컨텐츠 마크다운복사(재귀)",
		"10. 탐색기 목록 복사",
	})

	-- If user selects a valid option, copy the result to the clipboard
	if i > 0 then
		if i < 7 then
			local result = results[i]
			v.fn.setreg("+", result)
			v.notify("Copied: " .. result)
		elseif i == 7 and v.fn.isdirectory(filepath) == 0 then
			M.markdown_copy(filepath)
		elseif i == 8 and v.fn.isdirectory(filepath) == 1 then
			M.folder_markdown_copy(filepath, false)
		elseif i == 9 and v.fn.isdirectory(filepath) == 1 then
			M.folder_markdown_copy(filepath, true)
		elseif i == 10 then
			M.files_copy()
		else
			return v.notify("잘못입력하셨습니다: " .. i)
		end
	end
end

function M.folder_markdown_copy(folderpath, recursive)
	local pattern = recursive and "/**/*" or "/*"
	local files = v.fn.glob(folderpath .. pattern, false, true)
	local markdown_content = {}
	local parent = v.fn.fnamemodify(folderpath, ":h")
	local parent_len = #parent

	for _, filepath in ipairs(files) do
		if v.fn.isdirectory(filepath) == 0 then -- 파일인 경우만
			local file_ext = v.fn.fnamemodify(filepath, ":e")
			local file_content = v.fn.readfile(filepath)
			-- local relative_path = filepath:sub(#folderpath + 2) -- 상대 경로
			local relative_path = filepath:sub(parent_len + 2)

			table.insert(markdown_content, "```" .. file_ext .. " " .. relative_path)
			table.insert(markdown_content, table.concat(file_content, "\n"))
			table.insert(markdown_content, "```")
		end
	end

	if #markdown_content > 0 then
		local final_output = table.concat(markdown_content, "\n\n")
		v.fn.setreg("+", final_output)
		v.notify("\n폴더의 모든 파일이 마크다운 형식으로 클립보드에 복사되었습니다.")
	else
		v.notify("\n폴더에 파일이 없습니다.")
	end
end

function M.markdown_copy(filepath)
	-- 파일 경로로 파일 내용 읽기 (파일이 열려 있지 않으면 직접 파일 시스템에서 읽음)
	local isNeoTree = v.api.nvim_buf_get_name(0) ~= filepath -- 현재 버퍼의 파일 경로를 가져옵니다.
	local isEditor = v.api.nvim_buf_get_name(0) == filepath -- 현재 버퍼의 파일 경로를 가져옵니다.

	local file_content
	local file_ext = v.fn.fnamemodify(filepath, ":e")

	if isEditor then
		file_content = v.fn.join(v.fn.getline(1, "$"), "\n")
	elseif isNeoTree then
		file_content = v.fn.readfile(filepath)
		file_content = table.concat(file_content, "\n")
	end

	local cwd = v.fn.getcwd() -- 현재 작업 디렉토리
	local relative_path = filepath:sub(#cwd + 2)
	local markdown_code_block = "```" .. file_ext .. " " .. relative_path .. "\n" .. file_content .. "\n```"
	v.fn.setreg("+", markdown_code_block)
	v.notify("\n파일의 코드가 클립보드에 복사되었습니다: " .. relative_path)
end

function M.files_copy()
	local file_content = v.fn.join(v.fn.getline(1, "$"), "\n")
	v.fn.setreg("+", file_content)
	v.notify("\n탐색기의 정보가 클립보드에 복사되었습니다")
end

function M.run_file()
	local abs_file_path = v.fn.expand("%:p")
	local file_ext = v.fn.expand("%:e")

	local command

	if file_ext == "py" then
		command = string.format('python "%s"', abs_file_path)
	elseif file_ext == "js" or file_ext == "ts" then
		command = string.format('bun run "%s"', abs_file_path)
	elseif file_ext == "rs" then
		command = string.format("cargo run")
	else
		v.notify(
			"지원되지 않는 확장자입니다. nvim module_fn에 실행커맨드를 수정하세요: " .. file_ext
		)
		return
	end
	-- 명령어 실행
	v.cmd(string.format("!%s", command))
end

function M.build_package()
	local dir = v.fn.getcwd()
	local package_json = dir .. "/package.json"

	if v.fn.filereadable(package_json) == 1 then
		if v.fn.filereadable(dir .. "/yarn.lock") == 1 then
			v.cmd("!yarn build")
		elseif v.fn.filereadable(dir .. "/pnpm-lock.yaml") == 1 then
			v.cmd("!pnpm build")
		else
			v.cmd("!npm run build")
		end
	end
end

function M.toggle_inlay_hint()
	local bufnr = v.api.nvim_get_current_buf()
	-- v.lsp.inlay_hint.enable(bufnr, not v.lsp.inlay_hint.is_enabled(bufnr))
	v.lsp.inlay_hint.enable(bufnr, false)
end

function M.open_externally(state)
	local node = state.tree:get_node()
	local path = node:get_id()
	local ext = vim.fn.fnamemodify(path, ":e")

	local external_exts = {
		html = true,
		pdf = true,
	}

	if external_exts[ext] then
		local cmd = "open " .. vim.fn.shellescape(path)
		vim.fn.jobstart(cmd, { detach = true, shell = true })
		vim.notify("외부에서 열기: " .. path)
	else
		vim.notify("외부 열기를 지원하지 않는 파일입니다: " .. ext, vim.log.levels.WARN)
	end
end

function M.file_or_folder_size(state)
	local node = state.tree:get_node()
	local filepath = node:get_id()

	-- 파일인지 폴더인지 확인
	local stat = v.loop.fs_stat(filepath)
	local is_file = stat and stat.type == "file"

	-- du 명령어 실행 후 결과 가져오기
	local handle = io.popen("du -sh " .. v.fn.shellescape(filepath))
	local result = handle and handle:read("*a") or nil
	if handle then
		handle:close()
	end

	-- 결과 확인 및 처리
	if result then
		local size = result:match("^(%S+)")
		if size then
			local icon = is_file and "📄 파일 크기: " or "📂 폴더 크기: "
			v.notify(
				icon .. size .. "\n🗂 경로: " .. filepath,
				v.log.levels.INFO,
				{ title = "파일/폴더 용량" }
			)
		else
			v.notify(
				"⚠️ 용량 정보를 읽을 수 없습니다.\n출력값: " .. result,
				v.log.levels.WARN,
				{ title = "경고" }
			)
		end
	else
		v.notify("❌ 명령 실행 실패! 혹은 빈 결과 반환됨.", v.log.levels.ERROR, { title = "오류" })
	end
end

return M

```

```lua lua/config/neovide.lua

local v = vim
if v.g.neovide then
	-- scale
	v.g.neovide_scale_factor = 1
	-- padding
	v.g.neovide_padding_top = 8
	v.g.neovide_padding_left = 8
	v.g.neovide_padding_right = 0
	v.g.neovide_padding_bottom = 0
	-- blur
	v.g.neovide_window_blurred = true
	v.g.neovide_floating_blur_amount_x = 4.0
	v.g.neovide_floating_blur_amount_y = 4.0
	-- shadow
	v.g.neovide_floating_shadow = true
	v.g.neovide_floating_z_height = 10
	v.g.neovide_light_angle_degrees = 45
	v.g.neovide_light_radius = 5
	-- transparency
	-- v.g.neovide_transparency = 0.7 (Deprecated)
	v.g.neovide_opacity = 0.7
end

```

```lua lua/config/options.lua

local opt = vim.opt

-- vim.o.winwidth = 80
-- vim.o.winheight = 80
-- tab indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- search
opt.incsearch = true
opt.ignorecase = false
opt.smartcase = true

-- visual
-- opt.relativenumber = true
opt.number = true
opt.termguicolors = true
opt.signcolumn = "yes"

--- etc
opt.encoding = "UTF-8"
opt.cmdheight = 1
opt.scrolloff = 10
opt.mouse:append("a")

-- markdown link
opt.conceallevel = 2

---
vim.diagnostic.config({
	-- virtual_text = { current_line = true },
	virtual_lines = { current_line = true },
})

```

```lua lua/plugins/alpha.lua

return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			"",
			"",
			"     ...    .     ...         .       .x+=:.                                   _            .                        ",
			'  .~`"888x.!**h.-``888h.     @88>    z`    ^%                                 u            @88>                      ',
			" dX   `8888   :X   48888>    %8P        .   <k                   u.    u.    88Nu.   u.    %8P      ..    .     :    ",
			"'888x  8888  X88.  '8888>     .       .@8Ned8\"                 x@88k u@88c. '88888.o888c    .     .888: x888  x888.  ",
			'\'88888 8888X:8888:   )?""`  .@88u   .@^%8888"                 ^"8888""8888"  ^8888  8888  .@88u  ~`8888~\'888X`?888f` ',
			" `8888>8888 '88888>.88h.   ''888E` x88:  `)8b.                  8888  888R    8888  8888 ''888E`   X888  888X '888>  ",
			"   `8\" 888f  `8888>X88888.   888E  8888N=*8888                  8888  888R    8888  8888   888E    X888  888X '888>  ",
			'  -~` \'8%"     88" `88888X   888E   %8"    R88                  8888  888R    8888  8888   888E    X888  888X \'888>  ',
			"  .H888n.      XHn.  `*88!   888E    @8Wou 9%     88888888      8888  888R   .8888b.888P   888E    X888  888X '888>  ",
			' :88888888x..x88888X.  `!    888&  .888888P`      88888888     "*88*" 8888"   ^Y8888*""    888&   "*88%""*88" \'888!` ',
			' f  ^%888888% `*88888nx"     R888" `   ^"F                       ""   \'Y"       `Y"        R888"    `~    "    `"`   ',
			'      "**"`    "**""        ""                                                            ""                       ',
			"",
			"",
		}

		dashboard.section.buttons.val = {
			dashboard.button("e", "󰈔  > New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("f", "󰱼  > Find file", ":cd $HOME/Documents/ | Telescope find_files<CR>"),
			dashboard.button("t", "󰊄  > Find text", ":Telescope live_grep <CR>"),
			dashboard.button("m", "󰃃  > BookMarks", ":Telescope marks <CR>"),
			dashboard.button("r", "󰄉  > Recent", ":Telescope oldfiles<CR>"),
			dashboard.button("s", "󰒓  > Settings", ":cd $HOME/.config/nvim | Telescope find_files<CR>"),
			dashboard.button("q", "󰗼  > Quit NVIM", ":qa<CR>"),
		}

		alpha.setup(dashboard.opts)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "alpha",
			callback = function()
				vim.opt_local.relativenumber = false
			end,
		})
	end,
}

```

```lua lua/plugins/autopairs.lua

return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = true,
	-- use opts = {} for passing setup options
	-- this is equalent to setup({}) function
}

```

```lua lua/plugins/cmp.lua

return {
	{
		"hrsh7th/nvim-cmp",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				build = "make install_jsregexp",
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"rafamadriz/friendly-snippets",
			"roobert/tailwindcss-colorizer-cmp.nvim",
			"MeanderingProgrammer/render-markdown.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local tailwindcss_colorizer = require("tailwindcss-colorizer-cmp") -- Import the tailwind colorizer plugin
			local lspkind = require("lspkind")
			local v = vim

			-- Set up the tailwindcss-colorizer-cmp
			tailwindcss_colorizer.setup({ color_square_width = 2 })

			-- Add this section to extend filetypes
			require("luasnip").filetype_extend("javascriptreact", { "html" })
			require("luasnip").filetype_extend("typescriptreact", { "html" })
			-- load snippets
			require("luasnip.loaders.from_vscode").lazy_load()

local has_words_before = function()
    -- unpack 함수를 안전하게 가져옵니다.
    local unpack_func = table.unpack or unpack
    local line, col = unpack_func(vim.api.nvim_win_get_cursor(0))
    
    return col ~= 0 
        and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

			local function jumpable(dir)
				local luasnip_ok, luasnip = pcall(require, "luasnip")
				if not luasnip_ok then
					return false
				end

				local win_get_cursor = v.api.nvim_win_get_cursor
				local get_current_buf = v.api.nvim_get_current_buf

				---sets the current buffer's luasnip to the one nearest the cursor
				---@return boolean true if a node is found, false otherwise
				local function seek_luasnip_cursor_node()
					-- TODO(kylo252): upstream this
					-- for outdated versions of luasnip
					if not luasnip.session.current_nodes then
						return false
					end

					local node = luasnip.session.current_nodes[get_current_buf()]
					if not node then
						return false
					end

					local snippet = node.parent.snippet
					local exit_node = snippet.insert_nodes[0]

					local pos = win_get_cursor(0)
					pos[1] = pos[1] - 1

					-- exit early if we're past the exit node
					if exit_node then
						local exit_pos_end = exit_node.mark:pos_end()
						if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
							snippet:remove_from_jumplist()
							luasnip.session.current_nodes[get_current_buf()] = nil

							return false
						end
					end

					node = snippet.inner_first:jump_into(1, true)
					while node ~= nil and node.next ~= nil and node ~= snippet do
						local n_next = node.next
						local next_pos = n_next and n_next.mark:pos_begin()
						local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
							or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

						-- Past unmarked exit node, exit early
						if n_next == nil or n_next == snippet.next then
							snippet:remove_from_jumplist()
							luasnip.session.current_nodes[get_current_buf()] = nil

							return false
						end

						if candidate then
							luasnip.session.current_nodes[get_current_buf()] = node
							return true
						end

						local ok
						ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
						if not ok then
							snippet:remove_from_jumplist()
							luasnip.session.current_nodes[get_current_buf()] = nil

							return false
						end
					end

					-- No candidate, but have an exit node
					if exit_node then
						-- to jump to the exit node, seek to snippet
						luasnip.session.current_nodes[get_current_buf()] = snippet
						return true
					end

					-- No exit node, exit from snippet
					snippet:remove_from_jumplist()
					luasnip.session.current_nodes[get_current_buf()] = nil
					return false
				end

				if dir == -1 then
					return luasnip.in_snippet() and luasnip.jumpable(-1)
				else
					return luasnip.in_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable(1)
				end
			end

			cmp.setup({
				-- formatting = {
				-- 	format = tailwindcss_colorizer.formatter, -- Use tailwindcss-colorizer-cmp formatter
				-- },
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol", -- show only symbol annotations
						maxwidth = {
							-- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
							-- can also be a function to dynamically calculate max width such as
							-- menu = function() return math.floor(0.45 * vim.o.columns) end,
							menu = 50, -- leading text (labelDetails)
							abbr = 50, -- actual suggestion item
						},
						ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
						show_labelDetails = true, -- show labelDetails in menu. Disabled by default

						-- The function below will be called before any actual modifications from lspkind
						-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
						before = function(entry, vim_item)
							return tailwindcss_colorizer.formatter(entry, vim_item) -- Use tailwindcss-colorizer-cmp formatter
						end,
					}),
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					-- ["<C-b>"] = cmp.mapping.scroll_docs(-4), -- not work
					-- ["<C-d>"] = cmp.mapping.scroll_docs(4), -- not work
					["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
					["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						elseif jumpable(1) then
							luasnip.jump(1)
						elseif has_words_before() then
							-- cmp.complete()
							fallback()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-i>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				-- autocompletion sources
				sources = cmp.config.sources({
					-- { name = "cmp_luasnip" }, -- <-- 스니펫 소스를 버퍼 소스보다 위로 이동
					{ name = "nvim_lsp" }, -- lsp
					{ name = "codeium" }, -- codeium, windsurf
					{ name = "luasnip", max_item_count = 3 }, -- snippets
					{ name = "buffer", max_item_count = 5 }, -- text within current buffer
					{ name = "path", max_item_count = 3 }, -- file system paths
					{ name = "render-markdown" },
				}),
			})
		end,
	},
}

```

```lua lua/plugins/colorizer.lua

return {
	{
		"NvChad/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = { -- set to setup table
			filetypes = { "*" },
			user_default_options = {
				names = true, -- "Name" codes like Blue or blue
				RGB = true, -- #RGB hex codes
				RRGGBB = true, -- #RRGGBB hex codes
				RRGGBBAA = true, -- #RRGGBBAA hex codes
				AARRGGBB = false, -- 0xAARRGGBB hex codes
				rgb_fn = false, -- CSS rgb() and rgba() functions
				hsl_fn = false, -- CSS hsl() and hsla() functions
				css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
				css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
				-- Highlighting mode.  'background'|'foreground'|'virtualtext'
				mode = "background", -- Set the display mode
				-- Tailwind colors.  boolean|'normal'|'lsp'|'both'.  True is same as normal
				tailwind = true, -- Enable tailwind colors
				-- parsers can contain values used in |user_default_options|
				sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
				-- Virtualtext character to use
				virtualtext = "■",
				-- Display virtualtext inline with color
				virtualtext_inline = false,
				-- Virtualtext highlight mode: 'background'|'foreground'
				virtualtext_mode = "foreground",
				-- update color values even if buffer is not focused
				-- example use: cmp_menu, cmp_docs
				always_update = false,
			},
			-- all the sub-options of filetypes apply to buftypes
			buftypes = {},
			-- Boolean | List of usercommands to enable
			user_commands = true, -- Enable all or some usercommands
		},
	},
}

```

```lua lua/plugins/comment.lua

return {
	"numToStr/Comment.nvim",
	opts = {
		---Add a space b/w comment and the line
		padding = true,
		---Whether the cursor should stay at its position
		sticky = true,
		---Lines to be ignored while (un)comment
		ignore = nil,
		---LHS of toggle mappings in NORMAL mode
		toggler = {
			line = "gcc",
			block = "gbc",
		},
		---LHS of operator-pending mappings in NORMAL and VISUAL mode
		opleader = {
			---Line-comment keymap
			line = "gc",
			---Block-comment keymap
			block = "gb",
		},
		---LHS of extra mappings
		extra = {
			---Add comment on the line above
			above = "gcO",
			---Add comment on the line below
			below = "gco",
			---Add comment at the end of line
			eol = "gcA",
		},
		---Enable keybindings
		---NOTE: If given `false` then the plugin won't create any mappings
		mappings = {
			---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
			basic = true,
			---Extra mapping; `gco`, `gcO`, `gcA`
			extra = true,
		},
		---Function to call before (un)comment
		pre_hook = nil,
		---Function to call after (un)comment
		post_hook = nil,
	},
	lazy = false,
}

```

```lua lua/plugins/conform.lua

return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				svelte = { "prettierd", stop_after_first = true },
				rust = { "rustfmt" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = false,
			},
		})
	end,
	opts = {},
}

```

```lua lua/plugins/flash.lua

return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}

```

```lua lua/plugins/focus.lua

return {
	"nvim-focus/focus.nvim",
	version = "*",
	config = function()
		require("focus").setup({
			enable = true, -- 플러그인 활성화
			commands = true, -- Focus 관련 명령어 활성화

			-- 자동 크기 조절
			autoresize = {
				enable = true, -- 자동 크기 조절 활성화
				width = 0, -- 포커스된 창의 강제 가로 크기 (0이면 기본값 사용)
				height = 0, -- 포커스된 창의 강제 세로 크기 (0이면 기본값 사용)
				minwidth = 30, -- 포커스되지 않은 창의 최소 가로 크기
				minheight = 10, -- 포커스되지 않은 창의 최소 세로 크기
				height_quickfix = 10, -- QuickFix 창의 높이 설정 (기본값: 10줄)
			},

			-- 창 분할 설정
			split = {
				bufnew = false, -- 새로운 빈 버퍼를 열 때 자동으로 새 창을 만들지 여부
				tmux = false, -- Tmux 창을 사용해 창을 분할할지 여부
			},

			-- UI 설정
			ui = {
				-- number = true, -- 포커스된 창에서만 줄 번호 표시
				-- relativenumber = true, -- 포커스된 창에서만 상대 줄 번호 표시
				hybridnumber = true, -- 포커스된 창에서 하이브리드 번호(절대+상대) 사용 여부
				absolutenumber_unfocussed = false, -- 포커스되지 않은 창에서도 절대 번호 유지 여부

				cursorline = true, -- 포커스된 창에서만 커서라인 강조 표시
				cursorcolumn = false, -- 포커스된 창에서만 커서 컬럼 강조 표시
				colorcolumn = {
					enable = false, -- 포커스된 창에서 컬럼 강조선 표시 여부
					list = "+1", -- 강조할 컬럼 위치 (기본적으로 커서 기준 +1)
				},
				signcolumn = true, -- 포커스된 창에서만 `signcolumn` 표시 여부
				winhighlight = true, -- 포커스된 창과 비포커스 창을 자동으로 하이라이트할지 여부
			},
		})
	end,
}

```

```lua lua/plugins/gitgraph.lua

return {
	"isakbm/gitgraph.nvim",
	dependencies = { "sindrets/diffview.nvim" },
	opts = {
		git_cmd = "git",
		format = {
			timestamp = "%H:%M:%S %d-%m-%Y",
			fields = { "hash", "timestamp", "author", "branch_name", "tag" },
		},
		hooks = {
			-- Check diff of a commit
			on_select_commit = function(commit)
				vim.notify("DiffviewOpen " .. commit.hash .. "^!")
				vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
			end,
			-- Check diff from commit a -> commit b
			on_select_range_commit = function(from, to)
				vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
				vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
			end,
		},
		-- symbols = {
		-- 	merge_commit = "M",
		-- 	commit = "*",
		-- },
		symbols = {
			merge_commit = "",
			commit = "",
			merge_commit_end = "",
			commit_end = "",

			-- Advanced symbols
			GVER = "",
			GHOR = "",
			GCLD = "",
			GCRD = "╭",
			GCLU = "",
			GCRU = "",
			GLRU = "",
			GLRD = "",
			GLUD = "",
			GRUD = "",
			GFORKU = "",
			GFORKD = "",
			GRUDCD = "",
			GRUDCU = "",
			GLUDCD = "",
			GLUDCU = "",
			GLRDCL = "",
			GLRDCR = "",
			GLRUCL = "",
			GLRUCR = "",
		},
	},
	keys = {
		-- {
		-- 	"<leader>gl",
		-- 	function()
		-- 		require("gitgraph").draw({}, { all = true, max_count = 5000 })
		-- 	end,
		-- 	desc = "GitGraph - Draw",
		-- },
	},
}

```

```lua lua/plugins/image.lua

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

```

```lua lua/plugins/lapkind.lua

return {
	"onsails/lspkind.nvim",
	config = function()
		-- setup() is also available as an alias
		require("lspkind").init({
			-- DEPRECATED (use mode instead): enables text annotations
			--
			-- default: true
			-- with_text = true,

			-- defines how annotations are shown
			-- default: symbol
			-- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
			mode = "symbol_text",

			-- default symbol map
			-- can be either 'default' (requires nerd-fonts font) or
			-- 'codicons' for codicon preset (requires vscode-codicons font)
			--
			-- default: 'default'
			preset = "codicons",

			-- override preset symbols
			--
			-- default: {}
			symbol_map = {
				Text = "󰉿",
				Method = "󰆧",
				Function = "󰊕",
				Constructor = "",
				Field = "󰜢",
				Variable = "󰀫",
				Class = "󰠱",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "󰑭",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "󰈙",
				Reference = "󰈇",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "󰙅",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "",
			},
		})
	end,
}

```

```lua lua/plugins/lsp.lua

local map = require("utils.keyMapper").map

return {
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
      local wk = require("which-key")
      local M = require("config.module_fn")
      local v = vim

      -- LSP attach 시 인레이 힌트 등 설정
      v.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = v.lsp.get_client_by_id(args.data.client_id)
          -- if client.server_capabilities.inlayHintProvider then
          --   v.lsp.inlay_hint.enable(true)
          -- end
        end,
      })

      ----------------------------------------------------------------------
      -- Neovim 0.11+ 방식: vim.lsp.config / vim.lsp.enable
      ----------------------------------------------------------------------

      v.lsp.config("pyright", {
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

      v.lsp.config("lua_ls", {
        settings = {
          Lua = {
            hint = {
              enable = true,
            },
          },
        },
      })

      v.lsp.config("html", {})
      v.lsp.config("jsonls", {})
      v.lsp.config("markdown_oxide", {})
      v.lsp.config("taplo", {})
      v.lsp.config("tailwindcss", {})

      v.lsp.config("ts_ls", {
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

      v.lsp.config("svelte", {
        settings = {
          typescript = {
            -- inlayHints 설정 필요하면 여기
          },
        },
      })

      -- 실제로 사용할 서버 enable
      v.lsp.enable("pyright")
      v.lsp.enable("lua_ls")
      v.lsp.enable("html")
      v.lsp.enable("jsonls")
      v.lsp.enable("markdown_oxide")
      v.lsp.enable("taplo")
      v.lsp.enable("tailwindcss")
      v.lsp.enable("ts_ls")
      v.lsp.enable("svelte")
      -- 필요하면 여기서 다른 서버도 enable

      ----------------------------------------------------------------------
      -- 키맵
      ----------------------------------------------------------------------
      map("K", "<cmd>lua vim.lsp.buf.hover()<CR>")
      map("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")

      wk.add({
        { "<leader>l", group = "language service" },
        { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "code Action" },
        { "<leader>ld", v.diagnostic.setqflist, desc = "Diagnostic" },
        { "<leader>lr", ":LspRestart<CR>", desc = "lsp Restart" },
        -- { "<leader>lh", M.toggle_inlay_hint, desc = "inlay Hint" },
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
          desc = "open definition horizontal",
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

```

```lua lua/plugins/lualine.lua

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    })
  end,
}

```

```lua lua/plugins/luarocks.lua

return {
	"vhyrro/luarocks.nvim",
	priority = 1001, -- this plugin needs to run before anything else
	opts = {
		-- luarocks_dir = "~/.luarocks",
		-- rocks = { "magick" },
	},
}

```

```lua lua/plugins/markdown-preview.lua

return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = "cd app && yarn install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
	end,
	ft = { "markdown" },
}

```

```lua lua/plugins/maximizer.lua

return {
	"declancm/maximize.nvim",
	config = true,
}

```

```lua lua/plugins/mini.lua

return {
	"echasnovski/mini.nvim",
	version = "*",
	config = function()
		require("mini.icons").setup({
			icons = {
				-- 아이콘 스타일 설정 ('glyph' 또는 'ascii')
				style = "glyph", -- 'glyph' 스타일을 기본값으로 사용
				-- 각 카테고리별로 설정을 추가할 수 있습니다. 예시:
				default = {}, -- 기본 설정
				directory = {}, -- 디렉토리 설정
				extension = {}, -- 파일 확장자별 설정
				file = {}, -- 파일별 설정
				filetype = {}, -- 파일 유형별 설정
				lsp = {}, -- LSP 관련 설정
				os = {}, -- 운영체제 관련 설정
				-- 파일 확장자를 기반으로 아이콘을 사용할지 말지 제어하는 함수
				use_file_extension = function(ext, file)
					return true -- 여기서 'true'를 반환하면 모든 파일 확장자에 대해 아이콘을 사용
				end,
			},
		})
	end,
}

-- https://github.com/echasnovski/mini.nvim/tree/main?tab=readme-ov-file#installation

```

```lua lua/plugins/neodev.lua

return {
	"folke/neodev.nvim",
	opts = {},
	lazy = false, -- 바로 로드되도록 설정
}

```

```lua lua/plugins/neotree.lua

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim",
	},
	config = function()
		local v = vim
		local M = require("config.module_fn")

    -- Neovim 0.11+ 방식: vim.diagnostic.config 사용
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = "󰌵",
        },
      },
    })
    local function render_symlink_mark(config, node, state)
      if state.clipboard 
        and state.clipboard.action == "symlink"
        and tostring(node.path) == state.clipboard.path then
        return {
          text = " (s)",
          highlight = config.highlight or "NeoTreeDimText",
        }
      end
      return nil
    end

		require("neo-tree").setup({
			close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
			sort_case_insensitive = false, -- used when sorting files and directories in the tree
			sort_function = nil, -- use a custom function for sorting files and directories in the tree
			-- sort_function = function (a,b)
			--       if a.type == b.type then
			--           return a.path > b.path
			--       else
			--           return a.type > b.type
			--       end
			--   end , -- this sorts files and directories descendantly
			default_component_configs = {
        components = {
          symlink_mark = render_symlink_mark,
        },
				container = {
					enable_character_fade = true,
				},
        symlink_mark = {
          enabled = true,
          highlight = "NeoTreeDimText",
        },
				indent = {
					indent_size = 2,
					padding = 1, -- extra padding on left hand side
					-- indent guides
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					-- expander config, needed for nesting files
					with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰜌",
					-- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
					-- then these will never be used.
					default = "*",
					highlight = "NeoTreeFileIcon",
				},
				modified = {
					symbol = "[+]",
					highlight = "NeoTreeModified",
				},
				-- name = {
				-- 	trailing_slash = false,
				-- 	use_git_status_colors = true,
				-- 	highlight = "NeoTreeFileName",
				-- },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
          extra_prerender = function(state, node)
            if state.clipboard and state.clipboard.action == "symlink" and 
               tostring(node.path) == state.clipboard.path then
              return { { text = " (s)", hl_group = "NeoTreeDimText" } }
            end
          end,
        },
				git_status = {
					symbols = {
						-- Change type
						added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
						modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
						deleted = "✖", -- this can only be used in the git_status source
						renamed = "󰁕", -- this can only be used in the git_status source
						-- Status type
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
				-- If you don't want to use these columns, you can set `enabled = false` for each of them individually
				file_size = {
					enabled = true,
					required_width = 64, -- min width of window required to show this column
				},
				type = {
					enabled = true,
					required_width = 122, -- min width of window required to show this column
				},
				last_modified = {
					enabled = true,
					required_width = 88, -- min width of window required to show this column
				},
				created = {
					enabled = true,
					required_width = 110, -- min width of window required to show this column
				},
				symlink_target = {
					enabled = false,
				},
			},
			-- A list of functions, each representing a global custom command
			-- that will be available in all sources (if not overridden in `opts[source_name].commands`)
			-- see `:h neo-tree-custom-commands-global`
commands = {
  symlink_copy = function(state)
    local node = state.tree:get_node()
    if node then
      state.clipboard = { 
        name = node.name, 
        path = tostring(node.path), 
        action = "symlink" 
      }
      vim.notify("원본 저장됨: " .. node.name)
      require("neo-tree.sources.manager").refresh(state.name)
    end
  end,
  symlink_paste = function(state)
    local clipboard = state.clipboard
    if not clipboard or clipboard.action ~= "symlink" then
      vim.notify("C로 원본 선택하세요.", vim.log.levels.WARN)
      return
    end

    local node = state.tree:get_node()
    local target_dir = node and node.type == "directory" and tostring(node.path) 
                       or state.path or vim.fn.getcwd()

    local link_name = vim.fn.fnamemodify(clipboard.path, ":t")
    local full_link = target_dir .. "/" .. link_name
    local counter = 1
    while vim.fn.filereadable(full_link) == 1 do
      link_name = vim.fn.fnamemodify(clipboard.path, ":t:r") .. "_" .. counter .. "." .. vim.fn.fnamemodify(clipboard.path, ":e")
      full_link = target_dir .. "/" .. link_name
      counter = counter + 1
    end

    local ok, result = pcall(vim.fn.system, {"ln", "-s", clipboard.path, full_link})
    if ok and vim.v.shell_error == 0 then
      require("neo-tree.sources.manager").refresh(state.name)  -- 실시간 새로고침!
      vim.notify("생성됨 → " .. link_name .. " (in " .. vim.fn.fnamemodify(target_dir, ":t") .. ")")
    else
      vim.notify("실패: " .. (result or "권한 오류"), vim.log.levels.ERROR)
    end
  end,
},
			window = {
				position = "left",
				width = 40,
				mapping_options = {
					noremap = true,
					nowait = true,
				},
				mappings = {
					["<space>"] = {
						"toggle_node",
						nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
					},
					["<2-LeftMouse>"] = "open",
					["<cr>"] = "open",
					["l"] = "open",
					["<esc>"] = "cancel", -- close preview or floating neo-tree window
					["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
					-- Read `# Preview Mode` for more information
					["L"] = "focus_preview",
					["s"] = "open_split",
					["v"] = "open_vsplit",
					-- ["S"] = "split_with_window_picker",
					-- ["s"] = "vsplit_with_window_picker",
					-- ["t"] = "open_tabnew",
					-- ["<cr>"] = "open_drop",
					-- ["t"] = "open_tab_drop",
					-- ["w"] = "open_with_window_picker", -- need window picker
					--["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
					-- ["C"] = "close_node",
					["h"] = "close_node",
					-- ['C'] = 'close_all_subnodes',
					["z"] = "close_all_nodes",
					--["Z"] = "expand_all_nodes",
					["a"] = {
						"add",
						-- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
						-- some commands may take optional config options, see `:h neo-tree-mappings` for details
						config = {
							show_path = "none", -- "none", "relative", "absolute"
						},
					},
					["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
					["d"] = "delete",
					["r"] = "rename",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",
					["c"] = "copy_to_clipboard", -- takes text input for destination, also accepts the optional config.show_path option like "add":
          ["C"] = "symlink_copy",  -- 새: 심볼릭 원본 복사 (대문자 C)
          ["S"] = "symlink_paste",  -- 새: 심볼릭 붙여넣기 (대문자 S, 기존 s=vsplit과 구분)
					-- ["c"] = {
					--  "copy",
					--  config = {
					--    show_path = "none" -- "none", "relative", "absolute"
					--  }
					--}
					["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
					["q"] = "close_window",
					["R"] = "refresh",
					["?"] = "show_help",
					["<"] = "prev_source",
					[">"] = "next_source",
					["i"] = "show_file_details",
					["I"] = M.file_or_folder_size,
					["O"] = M.open_externally,
					-- ["Y"] = "copy_to_clipboard", same c
					["y"] = M.copy_file_info_to_clipboard,
				},
			},
			nesting_rules = {},
			filesystem = {
				filtered_items = {
					visible = false, -- when true, they will just be displayed differently than normal items
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_hidden = true, -- only works on Windows for hidden files/directories
					hide_by_name = {
						--"node_modules"
						"__pycache__",
					},
					hide_by_pattern = { -- uses glob style patterns
						--"*.meta",
						--"*/src/*/tsconfig.json",
						"._**", -- 이 줄을 추가합니다.
					},
					always_show = { -- remains visible even if other settings would normally hide it
						--".gitignored",
					},
					never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
						--".DS_Store",
						--"thumbs.db"
					},
					never_show_by_pattern = { -- uses glob style patterns
						--".null-ls_*",
					},
				},
				follow_current_file = {
					enabled = false, -- This will find and focus the file in the active buffer every time
					--               -- the current file is changed while the tree is open.
					leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
				},
				group_empty_dirs = false, -- when true, empty folders will be grouped together
				hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
				-- in whatever position is specified in window.position
				-- "open_current",  -- netrw disabled, opening a directory opens within the
				-- window like netrw would, regardless of window.position
				-- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
				use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
				-- instead of relying on nvim autocmd events.
				window = {
					mappings = {
						["<bs>"] = "navigate_up",
						["."] = "set_root",
						["H"] = "toggle_hidden",
						["/"] = "fuzzy_finder",
						["D"] = "fuzzy_finder_directory",
						["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
						-- ["D"] = "fuzzy_sorter_directory",
						["f"] = "filter_on_submit",
						["<c-x>"] = "clear_filter",
						["[g"] = "prev_git_modified",
						["]g"] = "next_git_modified",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["og"] = { "order_by_git_status", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
						-- ['<key>'] = function(state) ... end,
					},
					fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
						["<down>"] = "move_cursor_down",
						["<C-j>"] = "move_cursor_down",
						["<up>"] = "move_cursor_up",
						["<C-k>"] = "move_cursor_up",
						-- ['<key>'] = function(state, scroll_padding) ... end,
					},
				},
        renderers = {
          file = {
            { "icon" },
            { "name" },
            -- { "symlink_mark" },  -- 여기 추가
            -- { "diagnostics" },
            { "git_status" },
          },
          directory = {
            { "icon" },
            { "name" },
            -- { "symlink_mark" },  -- 여기도 추가
            -- { "diagnostics" },
            { "git_status" },
          },
        },

				commands = {}, -- Add a custom command or override a global one using the same function name
			},
			buffers = {
				follow_current_file = {
					enabled = true, -- This will find and focus the file in the active buffer every time
					--              -- the current file is changed while the tree is open.
					leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
				},
				group_empty_dirs = true, -- when true, empty folders will be grouped together
				show_unloaded = true,
				window = {
					mappings = {
						["bd"] = "buffer_delete",
						["<bs>"] = "navigate_up",
						["."] = "set_root",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
				},
			},
			git_status = {
				window = {
					position = "float",
					mappings = {
						["A"] = "git_add_all",
						["gu"] = "git_unstage_file",
						["ga"] = "git_add_file",
						["gr"] = "git_revert_file",
						["gc"] = "git_commit",
						["gp"] = "git_push",
						["gg"] = "git_commit_and_push",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
				},
			},
		})

		v.cmd([[nnoremap \ :Neotree reveal<cr>]])
	end,
}

```

```lua lua/plugins/notify.lua

return {
	"rcarriga/nvim-notify",
	-- `lazy = false`로 설정하여 Neovim 시작 시 바로 로드되도록 합니다.
	-- 알림 플러그인은 대부분 즉시 로드되는 것이 좋습니다.
	lazy = false,
	config = function()
		require("notify").setup({
			-- 여기에 원하는 설정을 추가합니다.
			-- 예를 들어:
			stages = "fade", -- 알림 애니메이션 스타일 (fade_in_slide_out, fade, slide)
			timeout = 2000, -- 알림이 사라지는 시간 (밀리초)
			max_height = 10, -- 최대 알림 개수 (줄 수)
			max_width = 80, -- 최대 알림 너비 (문자 수)
			-- 배치를 오른쪽 상단으로 설정하는 부분
			-- 기본적으로 오른쪽 상단에 표시됩니다.
			-- 추가적인 위치 조절이 필요하면 `top` 또는 `right` 값을 설정할 수 있습니다.
			-- 예를 들어, 더 오른쪽으로 붙이려면:
			render = "compact", -- 또는 "minimal" 등 다른 렌더링 스타일
			-- top = "5%", -- 상단으로부터의 거리 (백분율)
			-- right = "5%", -- 오른쪽으로부터의 거리 (백분율)
			-- 또는 함수를 사용하여 동적으로 위치를 지정할 수도 있습니다.
			-- https://github.com/rcarriga/nvim-notify#configuration 참고
			--
			-- highlight 옵션 (색상 설정)
			highlights = {
				INFO = "NotifyInfo",
				WARN = "NotifyWarn",
				ERROR = "NotifyError",
				DEBUG = "NotifyDebug",
				TRACE = "NotifyTrace",
			},
			-- 기타 설정:
			-- on_open = function(win) end, -- 알림 창이 열릴 때 실행될 함수
			-- on_close = function(win) end, -- 알림 창이 닫힐 때 실행될 함수
		})

		-- vim.notify를 nvim-notify로 오버라이드하여 다른 플러그인에서도 nvim-notify를 사용하도록 합니다.
		vim.notify = require("notify")
	end,
}

```

```lua lua/plugins/outline.lua

return {
	"hedyhli/outline.nvim",
	config = function()
		require("outline").setup({})

		-- 문서 버퍼(:q 등으로 나갈 때)마다 outline이 열려있고
		-- 남아있는 버퍼가 outline 뿐이면 자동으로 outline도 닫는다
		-- vim.api.nvim_create_autocmd("BufWinLeave", {
		-- 	callback = function()
		-- 		local outline = require("outline")
		-- 		if outline.is_open and outline.is_open() then
		-- 			local listed = vim.fn.getbufinfo({ buflisted = 1 })
		-- 			if #listed == 1 then
		-- 				-- outline 창 닫기
		-- 				outline.close()
		-- 			end
		-- 		end
		-- 	end,
		-- 	desc = "문서 버퍼가 다 닫힐 때 outline도 닫기",
		-- })
		vim.api.nvim_create_autocmd("BufWinLeave", {
			callback = function()
				local outline = require("outline")
				if outline.is_open and outline.is_open() then
					outline.close()
				end
			end,
			desc = "어떤 버퍼든 닫힐 때 outline도 같이 닫기",
		})
		-- vim.api.nvim_create_autocmd("BufWinLeave", {
		-- 	group = vim.api.nvim_create_augroup("OutlineAutoClose", { clear = true }),
		-- 	callback = function()
		-- 		-- Check if this is the last normal buffer
		-- 		local normal_buffers = 0
		-- 		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		-- 			if vim.api.nvim_buf_is_loaded(buf) then
		-- 				local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
		-- 				local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
		-- 				-- Count only normal document buffers (not outline, quickfix, etc.)
		-- 				if buftype == "" and filetype ~= "outline" then
		-- 					normal_buffers = normal_buffers + 1
		-- 				end
		-- 			end
		-- 		end
		--
		-- 		-- If no normal buffers remain, close outline window
		-- 		if normal_buffers == 0 then
		-- 			vim.schedule(function()
		-- 				require("outline").close()
		-- 			end)
		-- 		end
		-- 	end,
		-- })
	end,
}

```

```lua lua/plugins/plenary.lua

return {
	"nvim-lua/plenary.nvim",
}

```

```md lua/plugins/plugin-links.md

 alpha.lua             - Neovim 시작 시 표시되는 환영 화면(대문)을 아름답게 꾸며주는 플러그인이에요.
 autopairs.lua         - 괄호나 따옴표를 입력하면 자동으로 닫는 괄호/따옴표를 넣어주는 플러그인
 cmp.lua               - 강력한 자동 완성(Completion)
 colorizer.lua         - CSS 색상 코드(예: #FF0000, rgb(255,0,0))를 실제 색상으로 시각화
 comment.lua           - 코드 줄을 쉽게 주석 처리하거나 주석 해제
 conform.lua           - 다양한 코드 포맷터(Formatter)들을 통합 관리
 flash.lua             - f/F/t/T 명령어를 시각적으로 확장하여 빠르고 직관적인 커서 이동
 focus.lua             - 특정 창(window)이나 버퍼에 집중(focus)하거나 레이아웃을 관리하는 데 도움을 주는 플러그인일 거예요.
 hardtime.lua          - Vim의 기본 동작 방식(모달 편집)에 익숙해지도록 특정 키 바인딩 사용을 강제하거나 제한하는 훈련용 플러그인이에요.
 image.lua             - Neovim 버퍼 내에서 이미지를 미리 보기 
 indent-blankline.lua  - 수직 들여쓰기 가이드라인을 표시
 lsp.lua               - 언어 서버 프로토콜(LSP) 관련 설정
 lualine.lua           - 하단에 표시되는 상태 바(Statusline)
 luarocks.lua          - Lua 언어의 패키지 관리자인 LuaRocks 관련 설정
 markdown-preview.lua  - 실시간으로 렌더링된 마크다운을 미리 보기
 maximizer.lua         - 현재 작업 중인 창(window)을 최대화
 mini.lua              - 다양하고 작은 기능들을 한데 모아놓은 모듈형 플러그인 모음이에요.
 neodev.lua            - Lua 설정을 작성할 때 LSP가 vim 전역 객체를 포함한 Neovim API를 정확하게 인식
 neotree.lua           - 파일 탐색기
 notify.lua            - Neovim의 알림(Notification) 메시지
 outline.lua           - 현재 파일의 코드 구조(함수, 클래스 등)를 개요(Outline) 형태로 보여주는 플러그인
 plenary.lua           - Neovim 플러그인 개발에 유용한 다양한 Lua 유틸리티 함수들을 제공
 render-markdown.lua   - markdown-preview.lua와 유사하게 마크다운 렌더링
 tailwind-color.lua    - Tailwind CSS의 색상 유틸리티
 telescope.lua         - 퍼지 파인딩(Fuzzy Finding) 인터페이스를 제공. 파일, 버퍼, 명령 등을 빠르게 검색하고 이동
 themes.lua            - 여러 테마를 전환하는 로직
 toggle-terminal.lua   - 내장된 터미널을 쉽게 열고 닫을 수 있도록 도와주는 플러그인
 transparent.lua       - Neovim 배경의 투명도(Transparency)를 조절
 treesitter.lua        - 코드의 구문 구조를 파싱하여 구문 강조, 텍스트 객체, 접기(folding) 등
 ufo.lua               - 코드를 효율적으로 접고 펼치는(folding) 기능
 undo-tree.lua         - Vim/Neovim의 변경 내역(undo history)을 시각화 및 롤백
 vista.lua             - 코드의 개요(Outline)를 트리 형태로 표시하여 파일 내의 함수, 변수 등을 한눈에 파악
 whichkey.lua          - 키 바인딩을 입력할 때 다음에 입력할 수 있는 키맵을 팝업으로 보여줌

```

```lua lua/plugins/render-markdown.lua

return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		-- 표(Table) 관련 핵심 설정
		pipe_table = {
			-- 'full' 스타일은 모든 테두리를 깔끔한 선으로 그려줍니다.
			-- 'overlay' 스타일은 기존 문자를 가리며 더 정교하게 그립니다.
			style = "full",
			-- 표의 수직선(|)을 어떤 문자로 대체할지 결정합니다.
			border = {
				"┌",
				"┬",
				"┐",
				"├",
				"┼",
				"┤",
				"└",
				"┴",
				"┘",
				"│",
				"─",
			},
			-- 셀 내용 앞뒤로 여백을 주어 가독성을 높입니다.
			-- cell = "padded",
			-- 표의 가로 길이를 줄여서 줄 바꿈이 일어날 확률을 낮춰줍니다.
			cell = "trimmed",
			-- 정렬 기호(:---:)를 깔끔하게 숨기거나 아이콘으로 대체합니다.
			alignment_indicator = "━",
			-- anti_conceal을 활성화하면 커서가 표 위에 있을 때
			-- 렌더링이 풀리면서 표가 덜 깨져 보이게 도와줍니다.
			anti_conceal = {
				enabled = false,
			},
		},
		-- 표 외에도 전반적인 가독성을 위한 추가 옵션
		heading = {
			-- 헤딩 앞에 예쁜 아이콘을 붙여줍니다.
			sign = true,
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
			-- icons = { "Ⅰ ", "Ⅱ ", "Ⅲ ", "Ⅳ ", "Ⅴ ", "Ⅵ " },
			-- icons = { "▎ ", "▎ ", "▎ ", "▏ ", "▏ ", "▏ " },
			-- 아이콘 뒤에 배경색을 살짝 넣고 싶다면 아래 옵션을 추가할 수 있습니다.
			backgrounds = {
				"RenderMarkdownH1Bg",
				"RenderMarkdownH2Bg",
				"RenderMarkdownH3Bg",
				"RenderMarkdownH4Bg",
				"RenderMarkdownH5Bg",
				"RenderMarkdownH6Bg",
			},
		},
	},
}

```

```lua lua/plugins/rustacenvim.lua

return {
  'mrcjkb/rustaceanvim',
  version = '^6', -- 최신 메이저 버전 사용
  lazy = false,    -- Rust 파일 열 때 자동으로 로드됨
  config = function()
    vim.g.rustaceanvim = {
      server = {
        -- on_attach = function(client, bufnr)
        --   -- 여기에 Rust 전용 키매핑을 추가할 수 있습니다.
        -- end,
        default_settings = {
          ['rust-analyzer'] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" }, -- 저장 시 clippy 실행
          },
        },
      },
    }
  end
}

```

```lua lua/plugins/tailwind-color.lua

return {
	"roobert/tailwindcss-colorizer-cmp.nvim",
	-- optionally, override the default options:
	config = function()
		require("tailwindcss-colorizer-cmp").setup({
			color_square_width = 2,
		})
	end,
}

```

```lua lua/plugins/telescope.lua

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

```

```lua lua/plugins/themes.lua

return {
	{
		"zaldih/themery.nvim",
		lazy = false,
		config = function()
			require("themery").setup({
				themes = {
					"cyberdream",
					"rose-pine",
					"darkvoid",
					"oh-lucy",
					"tokyonight",
					-- "tokyonight-night",
					-- "tokyonight-storm",
					-- "tokyonight-day",
					-- "tokyonight-moon",
					-- "catppuccin",
					-- "catppuccin-frappe",
					-- "catppuccin-latte",
					-- "catppuccin-macchiato",
					-- "catppuccin-mocha",
					"solarized-osaka",
					-- "lackluster",
					-- "lackluster-dark",
					-- "lackluster-hack",
					"lackluster-mint",
					-- "lackluster-night",
					-- "nordic",
				}, -- 설치된 컬러스킴 목록
				livePreview = true, -- 테마 선택 시 바로 적용. 기본값은 true
			})
		end,
	},
	{
		"scottmckendry/cyberdream.nvim",
		lazy = false,
		priority = 1000,
	},
	{ "rose-pine/neovim", name = "rose-pine" },
	{ "aliqyan-21/darkvoid.nvim" },
	{ "Yazeed1s/oh-lucy.nvim" },
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		-- config = function()
		-- vim.cmd([[colorscheme catppuccin]])
		-- end,
		priority = 1000,
	},
	{
		"maxmx03/solarized.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- vim.cmd.colorscheme("solarized")
		end,
	},
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
		priority = 1000,
		config = function()
			-- vim.cmd.colorscheme("solarized-osaka")
		end,
		opts = function()
			return {
				transparent = true,
			}
		end,
	},
	{
		"AlexvZyl/nordic.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- require("nordic").load()
		end,
	},
	{
		"slugbyte/lackluster.nvim",
		lazy = false,
		priority = 1000,
		init = function()
			-- vim.cmd.colorscheme("lackluster")
			vim.cmd.colorscheme("lackluster-hack") -- my favorite
			-- vim.cmd.colorscheme("lackluster-mint")
		end,
	},
}

```

```lua lua/plugins/toggle-terminal.lua

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = true,
	opts = {
		direction = "float",
		start_in_insert = true,
		float_opts = {
			border = "curved",
		},
	},
}

```

```lua lua/plugins/transparent.lua

return {
  "tribela/vim-transparent",
}


```

```lua lua/plugins/treesitter.lua

local _ = require("utils.keyMapper").map

return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release varies by parser, so use master
  build = ":TSUpdate",
  branch = "master",
  main = "nvim-treesitter.configs", -- main module to load
  opts = {
    ensure_installed = {
      "svelte",
      "javascript",
      "typescript",
      "css",
      "html",
      "c",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "toml",
      "markdown",
      "markdown_inline",
    },
    sync_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    modules = {},
    ignore_install = {},
    auto_install = false,
  },
}

```

```lua lua/plugins/ufo.lua

local map = require("utils.keyMapper").map
return {
	-- fold plugin
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	config = function()
		local v = vim
		v.o.foldcolumn = "0" -- '0' is not bad
		v.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
		v.o.foldlevelstart = 99
		v.o.foldenable = true

		local ufo = require("ufo")
		local capabilities = v.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}
		local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
		for _, ls in ipairs(language_servers) do
			require("lspconfig")[ls].setup({
				capabilities = capabilities,
				-- you can add other fields for setting up lsp server in this table
			})
		end
		local handler = function(virtText, lnum, endLnum, width, truncate)
			local newVirtText = {}
			local suffix = (" 󰁂 %d "):format(endLnum - lnum)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0
			for _, chunk in ipairs(virtText) do
				local chunkText = chunk[1]
				local chunkWidth = vim.fn.strdisplaywidth(chunkText)
				if targetWidth > curWidth + chunkWidth then
					table.insert(newVirtText, chunk)
				else
					chunkText = truncate(chunkText, targetWidth - curWidth)
					local hlGroup = chunk[2]
					table.insert(newVirtText, { chunkText, hlGroup })
					chunkWidth = vim.fn.strdisplaywidth(chunkText)
					-- str width returned from truncate() may less than 2nd argument, need padding
					if curWidth + chunkWidth < targetWidth then
						suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
					end
					break
				end
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { suffix, "MoreMsg" })
			return newVirtText
		end
		ufo.setup({

			fold_virt_text_handler = handler,
			-- provider_selector = function(_, filetype, _)
			-- 	return { "lsp", "indent" }
			-- end,
			-- fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
			-- 	local newVirtText = {}
			-- 	local suffix = " { ... } " -- 원하는 폴딩 텍스트
			-- 	local sufWidth = vim.fn.strdisplaywidth(suffix)
			-- 	local targetWidth = width - sufWidth
			-- 	local curWidth = 0
			--
			-- 	for _, chunk in ipairs(virtText) do
			-- 		local chunkText = chunk[1]
			-- 		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
			-- 		if targetWidth > curWidth + chunkWidth then
			-- 			table.insert(newVirtText, chunk)
			-- 			curWidth = curWidth + chunkWidth
			-- 		else
			-- 			chunkText = truncate(chunkText, targetWidth - curWidth)
			-- 			table.insert(newVirtText, { chunkText, chunk[2] })
			-- 			curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
			-- 			break
			-- 		end
			-- 	end
			-- 	table.insert(newVirtText, { suffix, "Comment" })
			-- 	return newVirtText
			-- end,
		})

		map("zR", ufo.openAllFolds)
		map("zM", ufo.closeAllFolds)
	end,
}

```

```lua lua/plugins/undo-tree.lua

return {
	"mbbill/undotree",
}

```

```lua lua/plugins/venv-selector.lua

return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
		"mfussenegger/nvim-dap-python", -- 디버깅용 (선택사항이지만 있으면 좋음)
	},
	branch = "regexp", -- 성능이 더 좋은 최신 브랜치 사용 권장
	config = function()
		require("venv-selector").setup({
			settings = {
				options = {
					notify_user_on_venv_activation = true, -- 활성화시 알림
				},
			},
		})
	end,
	keys = {
		-- 단축키: <leader>v 를 누르면 가상환경 선택창이 뜹니다.
		{ "<leader>v", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
	},
}

```

```lua lua/plugins/whichkey.lua

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

```

```lua lua/plugins/windsurf.lua

return {
	"Exafunction/windsurf.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	config = function()
		require("codeium").setup({})
	end,
}

```

```lua lua/utils/keyMapper.lua

local keyMapper = function(from, to, mode, opts)
	local options = {
		noremap = true, -- normal mode
		silent = true, -- 뭐하는지 보임
	}
	local v = vim
	mode = mode or "n" -- 모드값을 사용하되 없으면 노멀모드에서 실행하라
	if opts then -- 매개변수에 옵션이 있다면 강제로 덥어쓰기 함
		options = v.tbl_extend("force", options, opts)
	end
	v.keymap.set(mode, from, to, options)
end

return { map = keyMapper }

```
