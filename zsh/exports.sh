export DOTFILES="$HOME/dotfiles-linux"

# 基本PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Claude Code
export PATH="$HOME/.local/bin:$PATH"

# dotfiles/scripts 配下のサブディレクトリ以下全てに PATH を通し、実行権限を与える。
if [ -d "$DOTFILES/scripts" ]; then
    export PATH="$PATH:$DOTFILES/scripts"
    for dir in "$DOTFILES"/scripts/*(/); do
        export PATH="$PATH:$dir"
    done
fi
chmod -R +x "$DOTFILES/scripts/"

# WSL: Windows の VS Code bin を PATH に追加（code コマンドを WSL から使うため）
if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    export PATH="$PATH:/mnt/c/Users/gyshi/AppData/Local/Programs/Microsoft VS Code/bin"
fi

# 重複除去
typeset -U path PATH
