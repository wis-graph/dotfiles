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

function M.zip_compress(state)
	local node = state.tree:get_node()
	local filepath = node:get_id()
	local filename = node.name
	local parent_dir = v.fn.fnamemodify(filepath, ":h")
	local zip_path = parent_dir .. "/" .. filename .. ".zip"

	if v.fn.filereadable(zip_path) == 1 then
		local overwrite = v.fn.confirm("이미 zip 파일이 존재합니다. 덮어쓸까요?", "&Yes\n&No", 2)
		if overwrite ~= 1 then
			return v.notify("압축 취소됨")
		end
	end

	local cmd
	if v.fn.isdirectory(filepath) == 1 then
		cmd = string.format("cd %s && zip -r %s %s", v.fn.shellescape(parent_dir), v.fn.shellescape(filename .. ".zip"), v.fn.shellescape(filename))
	else
		cmd = string.format("cd %s && zip %s %s", v.fn.shellescape(parent_dir), v.fn.shellescape(filename .. ".zip"), v.fn.shellescape(filename))
	end

	local result = v.fn.system(cmd)
	if v.v.shell_error == 0 then
		require("neo-tree.sources.manager").refresh(state.name)
		v.notify("압축 완료: " .. filename .. ".zip")
	else
		v.notify("압축 실패: " .. result, v.log.levels.ERROR)
	end
end

function M.save_image_from_clipboard(state)
	local node = state.tree:get_node()
	local target_dir

	if node.type == "directory" then
		target_dir = tostring(node.path)
	else
		target_dir = v.fn.fnamemodify(tostring(node.path), ":h")
	end

	local timestamp = os.date("%y%m%d_%H%M")
	local filename = "image_" .. timestamp .. ".png"
	local filepath = target_dir .. "/" .. filename

	local result = v.fn.system("pngpaste " .. v.fn.shellescape(filepath))

	if v.v.shell_error == 0 then
		require("neo-tree.sources.manager").refresh(state.name)
		v.notify("이미지 저장됨: " .. filename)
	else
		v.notify("클립보드에 이미지가 없거나 저장 실패: " .. result, v.log.levels.ERROR)
	end
end

function M.create_md_from_clipboard(state)
	local clipboard_content = v.fn.getreg("+")
	if clipboard_content == "" then
		return v.notify("클립보드가 비어있습니다.", v.log.levels.WARN)
	end

	local node = state.tree:get_node()
	local target_dir
	if node and node.type == "directory" then
		target_dir = tostring(node.path)
	elseif node then
		target_dir = v.fn.fnamemodify(tostring(node.path), ":h")
	else
		target_dir = state.path or v.fn.getcwd()
	end

	local filename = v.fn.input("파일명 입력 (확장자 제외): ")
	if filename == "" then
		return v.notify("취소되었습니다.")
	end

	local filepath = target_dir .. "/" .. filename .. ".md"

	if v.fn.filereadable(filepath) == 1 then
		local overwrite = v.fn.confirm("파일이 이미 존재합니다. 덮어쓸까요?", "&Yes\n&No", 2)
		if overwrite ~= 1 then
			return v.notify("취소되었습니다.")
		end
	end

	v.fn.writefile(v.split(clipboard_content, "\n"), filepath)
	require("neo-tree.sources.manager").refresh(state.name)
	v.notify("생성됨: " .. filename .. ".md")
end

return M
