# selimacerbas/markdown-preview.nvim

> **Note:** This repository was previously known as `mermaid-playground.nvim`. It has been renamed and rewritten to support full Markdown preview alongside first-class Mermaid diagram support.

Live **Markdown preview** for Neovim with first-class **Mermaid diagram** support.

- Renders your entire `.md` file in the browser — headings, tables, code blocks, everything
- **Mermaid diagrams** render inline as interactive SVGs (click to expand, zoom, pan, export)
- **Instant updates** via Server-Sent Events (no polling) with **scroll sync** — browser follows your cursor
- **Syntax highlighting** for code blocks (highlight.js)
- Dark / Light theme toggle with colored heading accents
- **Optional Rust-powered rendering** — use [`mermaid-rs-renderer`](https://github.com/mermaid-rs/mermaid-rs-renderer) for ~400x faster mermaid diagrams
- **Zero external dependencies** — no npm, no Node.js, just Neovim + your browser
- Powered by [`live-server.nvim`](https://github.com/selimacerbas/live-server.nvim) (pure Lua HTTP server)

---

## Quick start### Install (lazy.nvim){
  "selimacerbas/markdown-preview.nvim",
  dependencies \= { "selimacerbas/live-server.nvim" },
  config \= function()
    require("markdown\_preview").setup({
      \-- all optional; sane defaults shown
      port \= 8421,
      open\_browser \= true,
      debounce\_ms \= 300,
    })
  end,
}

No prereqs. No `npm install`. Just install and go.

### Use itOpen any Markdown file, then:

- **Start preview:** `:MarkdownPreview`
- **Edit freely** — the browser updates instantly as you type
- **Force refresh:** `:MarkdownPreviewRefresh`
- **Stop:** `:MarkdownPreviewStop`

> The first start opens your browser. Subsequent updates reuse the same tab.

**`.mmd` / `.mermaid` files** are fully supported — the entire file is rendered as a diagram.

For **other non-markdown files**, place your cursor inside a fenced ` ```mermaid ` block — the plugin extracts and previews just that diagram.

---

## Commands| Command | Description |
| --- | --- |
| `:MarkdownPreview` | Start preview |
| `:MarkdownPreviewRefresh` | Force refresh |
| `:MarkdownPreviewStop` | Stop preview |

No keymaps are set by default — map them however you like. Suggested:

vim.keymap.set("n", "<leader>mps", "<cmd>MarkdownPreview<cr>", { desc \= "Markdown: Start preview" })
vim.keymap.set("n", "<leader>mpS", "<cmd>MarkdownPreviewStop<cr>", { desc \= "Markdown: Stop preview" })
vim.keymap.set("n", "<leader>mpr", "<cmd>MarkdownPreviewRefresh<cr>", { desc \= "Markdown: Refresh preview" })

---

## Browser UIThe preview opens a polished browser app with:

- **Full Markdown rendering** — GitHub-flavored styling with colored heading borders, lists, tables, blockquotes, code, images, links, horizontal rules
- **Syntax-highlighted code blocks** — powered by highlight.js, with language badges
- **Interactive Mermaid diagrams** — rendered inline as SVGs:
	- Hover a diagram to reveal the **expand button**
	- Click to open a **fullscreen overlay** with zoom, pan, fit-to-width/height, and SVG export
- **Dark / Light theme** toggle (sun/moon icon in header)
- **Live connection indicator** — green dot when SSE is connected
- **Per-diagram error handling** — if one mermaid block is invalid, only that block shows an error; the rest of the page renders fine
- **Scroll sync** — browser follows your cursor position with line-level precision
- **Iconify auto-detection** — icon packs like `logos:google-cloud` are loaded on demand

---

## Configurationrequire("markdown\_preview").setup({
  port \= 8421,                          \-- server port
  open\_browser \= true,                  \-- auto-open browser on start

  content\_name \= "content.md",          \-- workspace content file
  index\_name \= "index.html",            \-- workspace HTML file
  workspace\_dir \= nil,                  \-- nil = per-buffer (recommended); set a path to override

  overwrite\_index\_on\_start \= true,      \-- copy plugin's index.html on every start

  auto\_refresh \= true,                  \-- auto-update on buffer changes
  auto\_refresh\_events \= {               \-- which events trigger refresh
    "InsertLeave", "TextChanged", "TextChangedI", "BufWritePost"
  },
  debounce\_ms \= 300,                    \-- debounce interval
  notify\_on\_refresh \= false,            \-- show notification on refresh

  mermaid\_renderer \= "js",              \-- "js" (browser mermaid.js) or "rust" (mmdr CLI, ~400x faster)

  scroll\_sync \= true,                   \-- browser follows cursor position
})

---

## Example<iframe title="File display" role="presentation" class="render-viewer" sandbox="allow-scripts allow-same-origin allow-top-navigation allow-popups" src="https://viewscreen.githubusercontent.com/markdown/mermaid?docs_host=https%3A%2F%2Fdocs.github.com&amp;color_mode=dark#8bf14024-f5eb-4488-9849-89b3ca11180f" name="8bf14024-f5eb-4488-9849-89b3ca11180f" data-content="{&quot;data&quot;:&quot;graph LR\n    A[Neovim Buffer] --&amp;gt;|write| B[content.md]\n    A -.-&amp;gt;|optional: mmdr| B\n    B --&amp;gt;|fs watch| C[live-server.nvim]\n    C --&amp;gt;|SSE| D[Browser]\n    D --&amp;gt; E[markdown-it]\n    D --&amp;gt; F[mermaid.js]\n    D --&amp;gt; G[highlight.js]\n    E --&amp;gt; H[Rendered Preview]\n    F --&amp;gt; H\n    G --&amp;gt; H\n&quot;}"></iframe>

Loading

graph LR
    A\[Neovim Buffer\] -->|write| B\[content.md\]
    A -.->|optional: mmdr| B
    B -->|fs watch| C\[live-server.nvim\]
    C -->|SSE| D\[Browser\]
    D --> E\[markdown-it\]
    D --> F\[mermaid.js\]
    D --> G\[highlight.js\]
    E --> H\[Rendered Preview\]
    F --> H
    G --> H

---

## How it works```
Neovim buffer
    |
    |  (autocmd: debounced write)
    v
workspace/content.md
    |
    |  (live-server.nvim detects change)
    v
SSE event --> Browser
    |
    |  markdown-it --> HTML
    |  mermaid.js  --> inline SVG diagrams
    |  highlight.js --> syntax highlighting
    |  morphdom    --> efficient DOM diffing
    v
Rendered preview (scroll preserved, no flicker)
```

- **Rust renderer** (`mermaid_renderer = "rust"`): mermaid fences are pre-rendered to SVG via the `mmdr` CLI before writing to `content.md` — the browser receives ready-made SVGs with no mermaid.js overhead. Failed blocks fall back to browser-side rendering automatically.
- **Markdown files**: The entire buffer is written to `content.md`
- **Mermaid files** (`.mmd`, `.mermaid`): The entire buffer is wrapped in a mermaid code fence
- **Other files**: The mermaid block under the cursor is extracted (via Tree-sitter or regex fallback) and wrapped in a code fence
- **SSE** (Server-Sent Events) from `live-server.nvim` push updates instantly — no polling
- **morphdom** diffs the DOM efficiently, preserving scroll position and interactive state
- **Per-buffer workspaces** under `~/.cache/nvim/markdown-preview/<hash>/` prevent collisions between Neovim instances

---

## Dependencies- **Neovim** 0.9+
- **[live-server.nvim](https://github.com/selimacerbas/live-server.nvim)** — pure Lua HTTP server (no npm)
- **Tree-sitter** with the **Markdown** parser (recommended for mermaid block extraction)
- **[mermaid-rs-renderer](https://github.com/mermaid-rs/mermaid-rs-renderer)** (optional) — `cargo install mermaid-rs-renderer` for ~400x faster mermaid rendering. Set `mermaid_renderer = "rust"` in config to enable.

Browser-side libraries are loaded from CDN (cached by your browser):

- [markdown-it](https://github.com/markdown-it/markdown-it) — Markdown parser
- [Mermaid](https://mermaid.js.org/) — diagram engine
- [highlight.js](https://highlightjs.org/) — syntax highlighting
- [morphdom](https://github.com/patrick-steele-idem/morphdom) — DOM diffing

---

## Troubleshooting**Browser shows nothing or "Loading..."**

- Make sure `live-server.nvim` is installed and loadable: `:lua require("live_server")`
- Check the port isn't in use: change `port` in config

**Mermaid diagram not rendering**

- The diagram syntax must be valid Mermaid — check the error chip on the diagram block
- Invalid diagrams show the last good render + error message

**Port conflict**

- Stop with `:MarkdownPreviewStop`, change `port` in config, restart with `:MarkdownPreview`

---

## Project structure```
markdown-preview.nvim/
├─ plugin/markdown-preview.lua       -- commands + keymaps
├─ lua/markdown_preview/
│  ├─ init.lua                       -- main logic (server, refresh, workspace)
│  ├─ util.lua                       -- fs helpers, workspace resolution
│  └─ ts.lua                         -- Tree-sitter mermaid extractor + fallback
└─ assets/
   └─ index.html                     -- browser preview app
```

---

## Thanks- [Mermaid](https://mermaid.js.org/) for the diagram engine
- [Iconify](https://iconify.design/) for icon packs
- [markdown-it](https://github.com/markdown-it/markdown-it) for Markdown parsing
- [highlight.js](https://highlightjs.org/) for syntax highlighting
- [morphdom](https://github.com/patrick-steele-idem/morphdom) for efficient DOM updates

PRs and ideas welcome!

## About

Live Markdown preview for Neovim with first-class Mermaid diagram support. Pure Lua, zero dependencies.

### Topics

[markdown](https://github.com/topics/markdown "Topic: markdown") [lua](https://github.com/topics/lua "Topic: lua") [neovim](https://github.com/topics/neovim "Topic: neovim") [preview](https://github.com/topics/preview "Topic: preview") [neovim-plugin](https://github.com/topics/neovim-plugin "Topic: neovim-plugin") [mermaid](https://github.com/topics/mermaid "Topic: mermaid")

### Resources

[Readme](https://github.com/selimacerbas/#readme-ov-file)

### License

[MIT license](https://github.com/selimacerbas/#MIT-1-ov-file)

### Uh oh!

There was an error while loading. Please reload this page.

[Activity](https://github.com/selimacerbas/markdown-preview.nvim/activity)

### Stars

[**54** stars](https://github.com/selimacerbas/markdown-preview.nvim/stargazers)

### Watchers

[**1** watching](https://github.com/selimacerbas/markdown-preview.nvim/watchers)

### Forks

[**5** forks](https://github.com/selimacerbas/markdown-preview.nvim/forks)

[Report repository](https://github.com/contact/report-content?content_url=https%3A%2F%2Fgithub.com%2Fselimacerbas%2Fmarkdown-preview.nvim&report=selimacerbas+%28user%29)

## [Releases 6](https://github.com/selimacerbas/markdown-preview.nvim/releases)

[

v1.3.0 Latest

Feb 16, 2026

](https://github.com/selimacerbas/markdown-preview.nvim/releases/tag/v1.3.0)

[\+ 5 releases](https://github.com/selimacerbas/markdown-preview.nvim/releases)

## [Packages 0](https://github.com/users/selimacerbas/packages?repo_name=markdown-preview.nvim)

No packages published  

## [Contributors 2](https://github.com/selimacerbas/markdown-preview.nvim/graphs/contributors)

- [![@selimacerbas](https://avatars.githubusercontent.com/u/91225118?s=64&v=4)](https://github.com/selimacerbas)[**selimacerbas** Selim Acerbas](https://github.com/selimacerbas)
- [![@claude](https://avatars.githubusercontent.com/u/81847?s=64&v=4)](https://github.com/claude)[**claude** Claude](https://github.com/claude)

## Languages

- [HTML 74.4%](https://github.com/selimacerbas/markdown-preview.nvim/search?l=html)
- [Lua 25.6%](https://github.com/selimacerbas/markdown-preview.nvim/search?l=lua)

## Footer© 2026 GitHub, Inc.

### Footer navigation

- [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
- [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
- [Security](https://github.com/security)
- [Status](https://www.githubstatus.com/)
- [Community](https://github.community/)
- [Docs](https://docs.github.com/)
- [Contact](https://support.github.com/?tags=dotcom-footer)
- 
-

You can’t perform that action at this time.

![](https://github.com/selimacerbas/icon/icon_32.png)
