#!/usr/bin/env bash
# Set up this config repo on a new machine (WSL Ubuntu). Safe to re-run.
#   git clone git@github.com:Av-sek/config.git ~/config && ~/config/install.sh
# Needs: git, curl, zsh. Neovim and WezTerm themselves are installed separately.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

# Point $2 at $1, moving any real file/folder already there to <name>.bak-<time>
link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok      $dst"
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.bak-$STAMP"
    echo "backup  $dst -> $dst.bak-$STAMP"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "link    $dst -> $src"
}

clone() {
  local url="$1" dst="$2"
  if [[ -d "$dst" ]]; then
    echo "ok      $dst"
  else
    git clone --depth=1 "$url" "$dst"
  fi
}

# --- Neovim ---
link "$DIR/nvim" "$HOME/.config/nvim"

# --- zsh: oh-my-zsh, Powerlevel10k, plugins ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
CUSTOM="$HOME/.oh-my-zsh/custom"
clone https://github.com/romkatv/powerlevel10k.git "$CUSTOM/themes/powerlevel10k"
clone https://github.com/zsh-users/zsh-autosuggestions.git "$CUSTOM/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM/plugins/zsh-syntax-highlighting"

for f in .zshrc .zshenv .zprofile .p10k.zsh; do
  link "$DIR/zsh/$f" "$HOME/$f"
done

# --- WezTerm (runs on Windows): a small loader in %USERPROFILE% that reads the repo copy over \\wsl.localhost ---
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  WIN_HOME="${WIN_HOME:-$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")}"
  STUB="$WIN_HOME/.wezterm.lua"
  P="$DIR/wezterm/wezterm.lua"
  WSL_PATH="\\\\\\\\wsl.localhost\\\\$WSL_DISTRO_NAME${P//\//\\\\}" # Lua string: \\wsl.localhost\Ubuntu\home\...
  NEW="-- Real config lives in the WSL repo: $DIR/wezterm/wezterm.lua
local wezterm = require(\"wezterm\")
local path = \"$WSL_PATH\"
wezterm.add_to_config_reload_watch_list(path)
return dofile(path)"
  if [[ -f "$STUB" && "$(cat "$STUB")" == "$NEW" ]]; then
    echo "ok      $STUB"
  else
    [[ -f "$STUB" ]] && mv "$STUB" "$STUB.bak-$STAMP" && echo "backup  $STUB -> $STUB.bak-$STAMP"
    printf '%s\n' "$NEW" > "$STUB"
    echo "write   $STUB"
  fi
else
  echo "skip    WezTerm loader (not in WSL)"
fi

echo
echo "Done. Machine-specific settings go in ~/.zshrc.local (not in the repo)."
[[ "$(basename "${SHELL:-}")" == zsh ]] || echo "Make zsh your default shell: chsh -s \"\$(command -v zsh)\""
