export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
export PATH="/opt/homebrew/Cellar/lua-language-server/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# brew
export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# zsh completions have been installed to:
  # /opt/homebrew/share/zsh/site-functions
  
# duckdb
# export DUCKDB_LIB_DIR="/opt/homebrew/opt/duckdb/lib"

# kuzu
# export KUZU_LIBRARY_DIR=/opt/homebrew/lib
# export KUZU_INCLUDE_DIR=/opt/homebrew/include
# export KUZU_SHARED=1

# gemini
# export GEMINI_API_KEY= "AIzaSyAEgnuD1tlTL6s_NBlnhc2rvg1y26lIqpY"

# jdk
# export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
# export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
# export PATH="$JAVA_HOME/bin:$PATH"

# export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

#  도커
export DOCKER_HOST=unix://$HOME/.colima/docker.sock
