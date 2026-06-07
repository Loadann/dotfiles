#!/bin/bash
# Arch / EndeavourOS installer for these dotfiles.
# (install.sh is the Ubuntu/WSL version — use this one on Arch-based systems.)
set -euo pipefail

# Resolve the dotfiles repo directory (where this script lives), so symlinks
# work no matter where the repo is cloned.
DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dependencies (pacman)..."
sudo pacman -Syu --needed --noconfirm \
  base-devel git curl unzip zsh \
  ripgrep fd nodejs npm python python-pip \
  neovim wl-clipboard \
  dotnet-sdk

echo "==> Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "    already present, skipping."
fi

echo "==> Installing zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_plugin() {
  local url="$1" dest="$2"
  if [ -d "$dest" ]; then
    echo "    $(basename "$dest") already present, skipping."
  else
    git clone --depth=1 "$url" "$dest"
  fi
}
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_plugin https://github.com/zsh-users/zsh-autosuggestions.git \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

echo "==> Symlinking dotfiles..."
backup() {
  if [ -e "$1" ] && [ ! -L "$1" ]; then
    mv "$1" "$1.bak.$(date +%s)" && echo "    backed up existing $1"
  fi
}
backup "$HOME/.zshrc"
ln -sfn "$DOTS/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.config"
backup "$HOME/.config/nvim"
ln -sfn "$DOTS/nvim" "$HOME/.config/nvim"

echo "==> Syncing Neovim plugins (LazyVim bootstrap)..."
nvim --headless "+Lazy! sync" +qa || echo "    (Lazy sync hit an error — open nvim manually to finish bootstrap.)"

echo "==> Setting zsh as default shell..."
if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)"
else
  echo "    already zsh, skipping."
fi

echo ""
echo "Done! Log out/in (or restart your terminal) to land in zsh."
