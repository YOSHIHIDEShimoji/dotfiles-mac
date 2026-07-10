export DOTFILES="$HOME/dotfiles"

# macOS base PATH
# 継承 PATH を破棄せず prepend する（#27）。破棄すると入れ子シェル（rr/sstyle の exec zsh・
# tmux 新ペイン）で venv・direnv・nvm 等が積んだ PATH が消える。伸長は末尾の typeset -U が除去。
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# VSCode CLI
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# tex path
export PATH="/Library/TeX/texbin:$PATH"

# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Java
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

# Claude Code
export PATH="$HOME/.local/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# dotfiles/scripts/bin 配下の実行ディレクトリに PATH を通す。
# 実行権限の付与は bootstrap で一度だけ行う（起動ごとの chmod -R は廃止＝#12）。
# lib/ や __pycache__ / john/wordlists など非実行ディレクトリは PATH に入れない。
if [ -d "$DOTFILES/scripts/bin" ]; then
    export PATH="$PATH:$DOTFILES/scripts/bin"
    for dir in "$DOTFILES"/scripts/bin/**/*(/N); do
        [[ "$dir" == *__pycache__* ]] && continue
        export PATH="$PATH:$dir"
    done
fi

# zsh のランタイム状態を repo 外へ退避（ZDOTDIR=repo のため既定では作業ツリーを汚す＝#13）
export HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
[ -d "${HISTFILE:h}" ] || mkdir -p "${HISTFILE:h}"
# macOS Terminal のセッション履歴（.zsh_sessions）を repo に作らせない
export SHELL_SESSIONS_DISABLE=1

# 履歴の量・保存挙動を dotfiles 側で明示する（#26）。
# 未設定だと /etc/zshrc の 1000 件で暗黙キャップされる。
export HISTSIZE=100000        # メモリに保持する行数
export SAVEHIST=100000        # HISTFILE に保存する行数（0 だと保存されない）
setopt INC_APPEND_HISTORY    # セッション終了を待たず随時追記（クラッシュしても失わない）
setopt EXTENDED_HISTORY      # タイムスタンプ付きで記録
setopt HIST_IGNORE_ALL_DUPS  # 既出コマンドは古い方を捨てて重複を残さない
setopt HIST_IGNORE_SPACE     # 先頭スペースで始めたコマンドは記録しない
setopt HIST_REDUCE_BLANKS    # 余分な空白を圧縮して記録

# 既定エディタ（gitconfig の core.editor と揃える＝#38）。
# 未設定だと git commit（-m なし）・crontab -e 等が vi にフォールバックする。
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# man をシンタックスハイライト（bat 不在でも無害なガード＝#38）
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"   # bat 経由時の下線・太字くずれ対策
fi

# less の履歴を repo/HOME 直下に散らかさない（#38）
export LESSHISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/less/history"

# ripgrep の共通設定（RIPGREP_CONFIG_PATH が指すファイルだけを rg は読む＝#41）
if [ -f "$DOTFILES/ripgrep/config" ]; then
  export RIPGREP_CONFIG_PATH="$DOTFILES/ripgrep/config"
fi

# fzf を fd/bat と連携（source <(fzf --zsh) は zshrc の後段で読むためここで env を先に置く＝#39）
if command -v fzf >/dev/null 2>&1; then
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --info=inline"
  if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || cat {}'"
  fi
  if command -v eza >/dev/null 2>&1; then
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} 2>/dev/null || ls {}'"
  fi
fi

# 重複除去
typeset -U path PATH
