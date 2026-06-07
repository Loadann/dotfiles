#!/bin/bash
# Interactive Arch / EndeavourOS setup for these dotfiles.
#
# Configs are SYMLINKED back into this repo (not copied), so anything you
# change on the machine is a change to the repo — just `git commit && push`
# from the dotfiles directory.
#
# Usage:
#   ./setup.sh        # ask y/n for each component
#   ./setup.sh -y     # assume yes to everything (non-interactive)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # dotfiles repo root
ARCH="$REPO/arch"

ASSUME_YES=0
case "${1:-}" in -y|--yes) ASSUME_YES=1 ;; esac

ask() {
  [ "$ASSUME_YES" = 1 ] && return 0
  local reply
  read -rp "$1 [Y/n] " reply </dev/tty
  case "$reply" in [nN]*) return 1 ;; *) return 0 ;; esac
}

# link <repo-path> <destination> — back up any real file, then symlink.
link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%s)"
    echo "    backed up existing $dest"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  echo "    linked $dest -> $src"
}

echo "Dotfiles setup — answer y/n for each component (default yes)."
echo ""

# 1. Native packages -------------------------------------------------------
if ask "==> Install native packages (pacman, full list)?"; then
  sudo pacman -Syu --needed - < "$ARCH/packages.txt"
fi

# 2. AUR packages ----------------------------------------------------------
if ask "==> Install AUR packages (spotify, heroic, proton-ge, ...)?"; then
  if ! command -v yay >/dev/null; then
    echo "    yay not found — bootstrapping yay-bin..."
    sudo pacman -S --needed --noconfirm git base-devel
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    ( cd "$tmp/yay-bin" && makepkg -si --noconfirm )
    rm -rf "$tmp"
  fi
  yay -S --needed - < "$ARCH/packages-aur.txt"
fi

# 3. Zsh + Oh My Zsh -------------------------------------------------------
if ask "==> Set up zsh (oh-my-zsh, plugins, .zshrc, default shell)?"; then
  command -v zsh >/dev/null || sudo pacman -S --needed --noconfirm zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  ZC="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  [ -d "$ZC/plugins/zsh-syntax-highlighting" ] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZC/plugins/zsh-syntax-highlighting"
  [ -d "$ZC/plugins/zsh-autosuggestions" ] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZC/plugins/zsh-autosuggestions"
  link "$REPO/.zshrc" "$HOME/.zshrc"
  if [ "$SHELL" != "$(command -v zsh)" ]; then chsh -s "$(command -v zsh)"; fi
fi

# 4. Neovim ----------------------------------------------------------------
if ask "==> Set up Neovim (symlink config + sync plugins)?"; then
  command -v nvim >/dev/null || sudo pacman -S --needed --noconfirm neovim
  link "$REPO/nvim" "$HOME/.config/nvim"
  nvim --headless "+Lazy! sync" +qa || echo "    (open nvim manually to finish bootstrap)"
fi

# 5. Hyprland --------------------------------------------------------------
if ask "==> Set up Hyprland config + screenshot scripts?"; then
  link "$ARCH/config/hypr" "$HOME/.config/hypr"
  link "$ARCH/bin/screenshot-region-copy" "$HOME/.local/bin/screenshot-region-copy"
  link "$ARCH/bin/screenshot-region-save" "$HOME/.local/bin/screenshot-region-save"
  echo "    NOTE: monitor layout in hyprland.conf is machine-specific — edit to taste."
  echo "    NOTE: wallpaper (~/Downloads/Kath.png in hyprpaper.conf) is not bundled."
fi

echo ""
echo "Done. Configs are symlinked into $REPO."
echo "Edit them in place, then:  cd $REPO && git add -A && git commit && git push"
