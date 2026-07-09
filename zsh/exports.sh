if [[ "$(uname)" == "Darwin" ]]; then
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
else
  export DOTFILES="$HOME/dotfiles-linux"

  # 基本PATH（WSL interop パス等の既存 PATH を保持しつつ基本パスを先頭に追加）
  export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

  # WSL: Windows の VS Code bin を PATH に追加（code コマンドを WSL から使うため）
  # Windows ユーザー名を glob で動的検出する（ハードコードを排除＝#30／他マシン移植性も向上）。
  if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    for _vsc in /mnt/c/Users/*/AppData/Local/Programs/"Microsoft VS Code"/bin(N); do
      export PATH="$PATH:$_vsc"
      break
    done
    unset _vsc
  fi
fi

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
# 未設定だと OS の rc 任せ = WSL は SAVEHIST=0 で保存されず、Mac は /etc/zshrc の 1000 件で暗黙キャップ。
export HISTSIZE=100000        # メモリに保持する行数
export SAVEHIST=100000        # HISTFILE に保存する行数（0 だと保存されない）
setopt INC_APPEND_HISTORY    # セッション終了を待たず随時追記（クラッシュしても失わない）
setopt EXTENDED_HISTORY      # タイムスタンプ付きで記録
setopt HIST_IGNORE_ALL_DUPS  # 既出コマンドは古い方を捨てて重複を残さない
setopt HIST_IGNORE_SPACE     # 先頭スペースで始めたコマンドは記録しない
setopt HIST_REDUCE_BLANKS    # 余分な空白を圧縮して記録

# 重複除去
typeset -U path PATH
