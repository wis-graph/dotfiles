# Zap  오마이즈쉬 사용안해도댐
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-completions"
plug "zsh-users/zsh-autosuggestions"
plug "hlissner/zsh-autopair"
plug "romkatv/powerlevel10k"
# $: p10k configure
#  이거 설정열어서 해야함

# 슈퍼차지
## cd 키워드 없이 폴더이동 가능, 
## git c등 명령어 이후 탭키 누르면 리스트업됨
plug "zap-zsh/supercharge"

# 단축키 알림 메시지
plug "MichaelAquilina/zsh-you-should-use"

# zoxide
plug "agkozak/zsh-z"
# zoxide auto completion
compdef _zshz ${ZSHZ_CMD:-${_Z_CMD:-z}}

# lsd 설치 필요

plug "zap-zsh/fzf"
plug "Aloxaf/fzf-tab"
plug "Freed-Wu/fzf-tab-source"
# 퍼지파인더 이거쓰면 Nvimtree 안부러움
# brew install fzf필요

# 기본 파인더 find -> fd
export FZF_DEFAULT_COMMAND="fd"

# 히스토리 사용시 라인넘버 숨기기
export FZF_CTRL_R_OPTS="
--preview 'bat {}'
--preview-window 'down:2:wrap' #보여주기형식
--bind 'ctrl-y:execute-silent(bat -n {2..} | pbcopy)+abort' # Ctrl-y 복사하기
--header '<Ctrl-Y> 커맨드 복사하기'
--exact
--expect=ctrl-x
"
#zshrc 파일





