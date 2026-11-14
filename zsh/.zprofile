# Mark profile as loaded so .zshrc can source this file for
# non-login shells without double-sourcing on login shells.
export PROFILE_SOURCED=1

# Load ~/.profile (sh-syntax) for PATH and environment shared with sh/bash
[[ -e "$HOME/.profile" ]] && emulate sh -c "source '$HOME/.profile'"

# Created by `pipx` on 2025-02-25 05:42:42
export PATH="$PATH:/home/abhishek/.local/bin"

# pyenv PATH setup (login shells only)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

