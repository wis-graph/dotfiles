
# aliases
alias vim='nvim'
alias v='nvim'
alias vi='neovide'
alias rc-nvim='nvim ~/.config/nvim/'
alias rc-lunarvim='nvim ~/.config/lvim/'
alias rc-kitty='nvim ~/.config/kitty/'
alias rc-zsh='nvim ~/.config/zsh/'
alias x='exit'
alias lvim='/Users/wistaria/.local/bin/lvim'
alias c='clear'
alias s='source $HOME/.zshrc'
alias start-yabai='yabai --start-service'
alias stop-yabai='yabai --stop-service'
alias start-skhd='skhd --start-service'
alias stop-skhd='skhd --stop-service'
alias remove="rm -rf"
# alias muse = "kew"
alias ip="curl -s https://checkip.org | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'"
# kitty term
alias icat="kitten icat"
# node pkg manager
alias pn="pnpm"
alias y="yarn"
# git
alias ga="git add ."
alias gc="git commit -m"
alias gps="git push"
alias gpl="git pull"
alias gch="git checkout"
alias gb="git branch"
alias glg="git log --graph --oneline --all --decorate"

alias git-add="git add ."
alias git-commit="git commit -m"
alias git-push="git push"
alias git-pull="git pull"
alias git-checkout="git checkout"
alias git-branch="git branch"
alias git-log="git log --graph --oneline --all --decorate"

# brew install lsd  필요
alias ll='lsd -l' # list
alias lf='lsd -f' # files
alias la='lsd -a' # all
alias lla='lsd -la' # list all
alias lt='lsd --tree'
alias ltd='lsd --tree -d'
alias ltg='lsd -l --git' # git status 포함
alias lti='lsd --tree --icon always'  # 아이콘 트리
alias ld='lsd --tree -d'

# python3
alias py='python3'
alias pip='pip3'
alias pipi='pip install -r requirements.txt'
alias whichpy='which python3' # 가상환경 뭐쓰는지 확인하기
alias pyinit='python3 -m venv .venv' # 가상환경 생성하기. 뒤에 이름
alias pyactivate='source .venv/bin/activate' # 가상환경 폴더가서 실행하면 해당 가상환경 진입
# deactivate -- 가상환경 종료

# displayplacer : homebrew app
alias dp='displayplacer' # raycast 검색 이용
alias tm="task-master"

function mc {
  mkdir -p $1
  cd $1
}
function del {
  rm -rf $1
}

setopt COMPLETE_ALIASES
