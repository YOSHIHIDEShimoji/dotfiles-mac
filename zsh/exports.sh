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

# 重複除去
typeset -U path PATH
