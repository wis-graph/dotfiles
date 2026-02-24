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
