export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# VSCode CLI
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# tex path
export PATH="/Library/TeX/texbin:$PATH"

# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# dotfiles-mac/scripts 配下のサブディレクトリ以下全てに PATH を通し、実行権限を与える。
if [ -d "$HOME/dotfiles-mac/scripts" ]; then
    export PATH="$PATH:$HOME/dotfiles-mac/scripts"
    for dir in $HOME/dotfiles-mac/scripts/*(/); do
        export PATH="$PATH:$dir"
    done
fi

chmod -R +x ~/dotfiles-mac/scripts/

# 重複除去
typeset -U path PATH

# 変数設定
export DOTFILES="$HOME/dotfiles-mac"
export SEM="$HOME/Library/CloudStorage/GoogleDrive-g.y.shimoji@gmail.com/マイドライブ/Chiba-u(drive)/2nd/sem2"