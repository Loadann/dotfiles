#!/bin/bash
# Ubuntu/Debian (WSL) installer for these dotfiles.
# (install-arch.sh is the Arch/EndeavourOS version.)
set -e

# Resolve the dotfiles repo directory (where this script lives), so symlinks
# work no matter where the repo is cloned.
DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dependencies..."
sudo apt update && sudo apt install -y \
  build-essential git curl unzip zsh \
  ripgrep fd-find nodejs npm python3 python3-pip

echo "==> Installing Neovim..."
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -xzf nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim          # avoid nesting if a previous install exists
sudo mv nvim-linux-x86_64 /opt/nvim
rm nvim-linux-x86_64.tar.gz

echo "==> Installing win32yank..."
curl -sLo /tmp/win32yank.zip \
  https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
unzip -o /tmp/win32yank.zip -d /tmp/win32yank
chmod +x /tmp/win32yank/win32yank.exe
sudo mv /tmp/win32yank/win32yank.exe /usr/local/bin/

echo "==> Installing .NET SDK..."
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update && sudo apt install -y dotnet-sdk-8.0
rm packages-microsoft-prod.deb

echo "==> Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "==> Installing zsh plugins..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "==> Symlinking dotfiles..."
ln -sfn "$DOTS/.zshrc" ~/.zshrc
mkdir -p ~/.config
ln -sfn "$DOTS/nvim" ~/.config/nvim
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd

echo "==> Installing LazyVim..."
# nvim will bootstrap itself on first launch
/opt/nvim/bin/nvim --headless "+Lazy! sync" +qa

echo "==> Setting zsh as default shell..."
chsh -s $(which zsh)

echo ""
echo "Done! Restart your terminal and you're good to go."
