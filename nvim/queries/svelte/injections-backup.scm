; extends

; Svelte Script Tag (TypeScript/JavaScript)
(script_element
  (raw_text) @injection.content
  (#injection.language "typescript"))

; 혹시 몰라 최신 파서용 노드 이름도 추가 (Svelte 5 대응)
(script_declaration
  (raw_text) @injection.content
  (#injection.language "typescript"))

; Svelte Style Tag (CSS)
(style_element
  (raw_text) @injection.content
  (#injection.language "css"))

; 최신 파서용 style
(style_declaration
  (raw_text) @injection.content
  (#injection.language "css"))
