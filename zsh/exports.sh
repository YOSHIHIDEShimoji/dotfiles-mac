# Homebrew python & git を最優先
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# dotfiles repo root
export DOTFILES="$HOME/dotfiles-mac"

# $ZDOTDIR/scripts/
export PATH="$HOME/dotfiles-mac/scripts:$PATH"

# tex path
export PATH="/Library/TeX/texbin:$PATH"

# VSCode CLI
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# PATH の重複を除去（zsh専用）
typeset -U path PATH

