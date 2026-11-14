# Ensure login-profile files (~/.zprofile, which also loads ~/.profile)
# run even when the terminal starts zsh as a non-login shell.
typeset -U path PATH  # keep PATH entries unique
if [[ ! -o login && -z "$PROFILE_SOURCED" && -r "$HOME/.zprofile" ]]; then
    source "$HOME/.zprofile"
fi

# -------------------------------
# pyenv PATH setup (MUST be before instant prompt and Oh My Zsh)
# Suppress output to avoid instant prompt warnings
# -------------------------------
# (pyenv PATH is set by ~/.zprofile above; the omz pyenv plugin runs `pyenv init -`)

# 1. Instant prompt (after PATH is set up)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
ZSH_THEME="powerlevel10k/powerlevel10k"
#Plugins (must be defined BEFORE sourcing Oh My Zsh)
plugins=(git gitfast python pip pyenv docker zsh-autosuggestions zsh-syntax-highlighting)

# Skip the slow completion-dir permission check (single-user machine)
ZSH_DISABLE_COMPFIX=true

source $ZSH/oh-my-zsh.sh

# -------------------------------
# Powerlevel10k prompt configuration
# -------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# -------------------------------
# pyenv shell integration & virtualenvwrapper
# -------------------------------

# virtualenvwrapper is installed for the system Python (~/.local), so pin that
# interpreter. `pyenv which python` follows the current dir's .python-version
# or an active venv, neither of which has virtualenvwrapper installed.
export WORKON_HOME="$HOME/Envs"
if [[ -r "$HOME/.local/bin/virtualenvwrapper.sh" ]]; then
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source "$HOME/.local/bin/virtualenvwrapper_lazy.sh"  # loads on first workon/mkvirtualenv
fi

# -------------------------------
# Node.js (nvm)
# -------------------------------
# Default node goes on PATH now; nvm itself (~0.6s) loads the first time you run `nvm`.
export NVM_DIR="$HOME/.nvm"
() {
  local v=$(<"$NVM_DIR/alias/default")
  # ponytail: non-version aliases (node, lts/*) fall back to the newest installed node
  [[ $v == v* ]] || v=(${NVM_DIR}/versions/node/*(N/nOn[1]:t))
  path=("$NVM_DIR/versions/node/$v/bin" $path)
}
nvm() {
  unfunction nvm
  source "$NVM_DIR/nvm.sh"
  source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# -------------------------------
# Custom PATH and environment variables
# -------------------------------
export PATH="$HOME/bin:$PATH"
export PATH="$PATH:/snap/bin"

# -------------------------------
# Optional aliases (uncomment or add your own)
alias zshconfig="vi ~/.zshrc"
# alias ohmyzsh="nano ~/.oh-my-zsh"


# -------------------------------
# Aliases (optional)
# -------------------------------
alias ll='ls -lah'
alias gs='git status'

export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

#code() {
#    if [[ "$1" != "." && "$1" != ".." && "$1" != */* ]]; then
#        local PROJECT_DIR="$HOME/Github/$1"
#	echo $PROJECT_DIR
#        if [ -d "$PROJECT_DIR" ]; then
#            command code "$PROJECT_DIR"
#            return
#        fi
#    fi
#
#    command code "$@"
#}

# opencode
export PATH=/home/abhishek/.opencode/bin:$PATH
export PATH="$PATH:$HOME/.dotnet/tools"

# Machine-specific / work settings (not in the repo)
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
