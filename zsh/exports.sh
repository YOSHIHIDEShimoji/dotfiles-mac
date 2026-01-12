export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# VSCode CLI
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# tex path
export PATH="/Library/TeX/texbin:$PATH"

# dotfiles scripts
export PATH="$HOME/dotfiles-mac/scripts:$PATH"

# Homebrew (最優先にしたいので、下の方に書くか、最後に結合する)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# 重複除去
typeset -U path PATH

# 変数設定
export DOTFILES="$HOME/dotfiles-mac"
export SEM="$HOME/Library/CloudStorage/GoogleDrive-g.y.shimoji@gmail.com/マイドライブ/Chiba-u(drive)/2nd/sem2"