# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
export PATH="/opt/homebrew/Cellar/lua-language-server/bin:$PATH"

# jdk
# export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
# export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
# export PATH="$JAVA_HOME/bin:$PATH"

# pnpm
# export PNPM_HOME="/Users/wistaria/Library/pnpm"
# export PATH="$PNPM_HOME:$PATH"

# export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# brew
# export DYLD_FALLBACK_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_FALLBACK_LIBRARY_PATH"
export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"

# android cli
# export ANDROID_HOME=~/.android/cli
# export PATH=$PATH:$ANDROID_HOME/bin

# asdf 자바 홈 만들기
# export PATH="/Users/wistaria/.asdf/shims:$PATH"
# . ~/.asdf/plugins/java/set-java-home.zsh


# e.g. ~/.profile or ~/.zshrc:
# . /opt/homebrew/opt/asdf/libexec/asdf.sh
# e.g. ~/.config/fish/config.fish
# source /opt/homebrew/opt/asdf/libexec/asdf.fish
# Restart your terminal for the settings to take effect.

# zsh completions have been installed to:
  # /opt/homebrew/share/zsh/site-functions
  #
# duckdb
# export DUCKDB_LIB_DIR="/opt/homebrew/opt/duckdb/lib"
# kuzu
# export KUZU_LIBRARY_DIR=/opt/homebrew/lib
# export KUZU_INCLUDE_DIR=/opt/homebrew/include
# export KUZU_SHARED=1


# gemini
# export GEMINI_API_KEY= "AIzaSyAEgnuD1tlTL6s_NBlnhc2rvg1y26lIqpY"
