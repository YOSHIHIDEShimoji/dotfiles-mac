# OS判定
if [[ "$(uname)" == "Darwin" ]]; then
  export DOTFILES="$HOME/dotfiles-mac"
elif [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  export DOTFILES="$HOME/dotfiles-linux"
else
  export DOTFILES="$HOME/dotfiles-linux"
fi

# 基本PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Claude Code / その他 ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# macOS固有PATH
if [[ "$(uname)" == "Darwin" ]]; then
  # Homebrew (Apple Silicon)
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

  # VSCode CLI
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

  # MacTeX
  export PATH="/Library/TeX/texbin:$PATH"

  # Java (Homebrew)
  export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
fi

# dotfiles/scripts 配下のサブディレクトリを PATH に追加し実行権限を付与
if [ -d "$DOTFILES/scripts" ]; then
  export PATH="$PATH:$DOTFILES/scripts"
  for dir in "$DOTFILES"/scripts/*/; do
    [[ -d "$dir" ]] && export PATH="$PATH:$dir"
  done
  chmod -R +x "$DOTFILES/scripts/"
fi

# 重複除去
typeset -U path PATH
