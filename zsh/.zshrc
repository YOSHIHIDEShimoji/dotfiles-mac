ZDOTDIR=~/dotfiles-mac/zsh

# 基本設定
source $ZDOTDIR/exports.sh
source $ZDOTDIR/aliases.sh
source $ZDOTDIR/functions.sh

# プラグイン読み込み（*.zsh or plugin ディレクトリ内の *.zsh）
for plugin in $ZDOTDIR/plugins/*.zsh(N) $ZDOTDIR/plugins/*/*.zsh(N); do
	source "$plugin"
done

# 補完（早めに初期化）
autoload -Uz compinit && compinit

# zsh-syntax-highlighting は最後！
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# テーマ
source $ZDOTDIR/themes/my-zsh-theme

# zoxide
eval "$(zoxide init zsh)"
