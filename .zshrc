# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme — pairs well with Tokyo Night
ZSH_THEME="agnoster"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  z                      # jump to frecent dirs with: z myproject
  dotnet                 # dotnet completions
  node
  npm
)

source $ZSH/oh-my-zsh.sh

# --- PATH ---
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$PATH:/opt/nvim/bin"
export PATH="$PATH:$HOME/.local/bin"   # fd symlink lives here

# --- .NET ---
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# --- Aliases ---
alias v="nvim"
alias vim="nvim"
alias ll="ls -lah"
alias gs="git status"
alias gc="git commit"
alias gp="git push"
command -v fdfind >/dev/null && alias fd="fdfind"   # Debian/WSL only; Arch ships it as `fd`

# --- History ---
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
