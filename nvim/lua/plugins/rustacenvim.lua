return {
	"mrcjkb/rustaceanvim",
	version = "^6", -- 최신 메이저 버전 사용
	ft = "rust",
	lazy = false, -- Rust 파일 열 때 자동으로 로드됨
	config = function()
		vim.g.rustaceanvim = {
			server = {
				-- on_attach = function(client, bufnr)
				--   -- 여기에 Rust 전용 키매핑을 추가할 수 있습니다.
				-- end,
				default_settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						checkOnSave = { command = "clippy" }, -- 저장 시 clippy 실행
					},
				},
			},
		}
	end,
}
