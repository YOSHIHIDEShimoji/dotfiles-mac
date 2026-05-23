if [[ "$(uname)" == "Darwin" ]]; then
  export DOTFILES="$HOME/dotfiles-mac"

  # macOS base PATH
  export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

  # VSCode CLI
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

  # tex path
  export PATH="/Library/TeX/texbin:$PATH"

  # Homebrew
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

  # Java
  export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
else
  export DOTFILES="$HOME/dotfiles-linux"

  # 基本PATH（WSL interop パス等の既存 PATH を保持しつつ基本パスを先頭に追加）
  export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

  # WSL: Windows の VS Code bin を PATH に追加（code コマンドを WSL から使うため）
  if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    export PATH="$PATH:/mnt/c/Users/gyshi/AppData/Local/Programs/Microsoft VS Code/bin"
  fi
fi

# Claude Code
export PATH="$HOME/.local/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# dotfiles/scripts 配下のサブディレクトリ以下全てに PATH を通し、実行権限を与える。
if [ -d "$DOTFILES/scripts" ]; then
    export PATH="$PATH:$DOTFILES/scripts"
    for dir in "$DOTFILES"/scripts/**/*(/); do
        export PATH="$PATH:$dir"
    done
fi
chmod -R +x "$DOTFILES/scripts/"

# 重複除去
typeset -U path PATH
