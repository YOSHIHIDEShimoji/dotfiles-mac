#!/usr/bin/env zsh
set -euo pipefail

: ${ZDOTDIR:?ZDOTDIR is not set. Please export it before running this script.}

# === Config ===============================================================
USE_VSCODE=${USE_VSCODE:-1}          # 1: VS Code拡張（LaTeX Workshop）を入れる
MAKE_SAMPLE=${MAKE_SAMPLE:-1}        # 1: サンプルプロジェクトを作る
SAMPLE_DIR="${HOME}/latex-sample"    # サンプルプロジェクトをホーム直下に固定
# ==========================================================================

print_step() { print -- "\n==> $1"; }

# 0) Homebrew
print_step "Homebrew の確認"
if ! command -v brew >/dev/null 2>&1; then
  print "Homebrew が見つかりません。インストールします。"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon / Intel 双方に対応して環境変数を反映
  if [[ -r /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -r /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  print "Homebrew は既に存在します。brew update を実行します。"
  brew update
fi

# 1) MacTeX (TeX Live 相当)
print_step "MacTeX のインストール（texlive-full 相当）"
if ! brew list --cask mactex >/dev/null 2>&1; then
  brew install --cask mactex
else
  print "MacTeX はインストール済みです。"
fi

# 2) PATH（/Library/TeX/texbin）は zsh/exports.sh が正（Darwin ブロックに固定）。
#    追跡ファイルへの追記はしない（二重管理・冪等性の脆さを排除 = #15）。現セッションにだけ通す。
TEXBIN="/Library/TeX/texbin"
print_step "PATH は zsh/exports.sh で管理済み（現セッションにのみ $TEXBIN を反映）"
export PATH="$TEXBIN:$PATH"


# 3) 日本語フォント（IPAex / IPA）— tap は不要
print_step "日本語フォント（IPAex / IPA）のインストール（tap なし）"

# 旧 tap の残骸があれば黙って外す（無ければ無視）
brew untap homebrew/cask-fonts 2>/dev/null || true

for c in font-ipaexfont font-ipafont; do
  if ! brew list --cask "$c" >/dev/null 2>&1; then
    brew install --cask "$c"
  else
    print "$c はインストール済みです。"
  fi
done

# 4) 動作確認（LaTeX コマンド類）
print_step "LaTeX コマンドの確認"
if ! command -v lualatex >/dev/null 2>&1; then
  print "lualatex が見つかりません。PATH 設定を確認してください。"
  exit 1
fi
print "lualatex: $(command -v lualatex)"
print "tlmgr:    $(command -v tlmgr || print -- 'not found（新しいシェルでPATH再読み込みが必要な場合があります）')"

# 5) VS Code 拡張
if [[ "$USE_VSCODE" == "1" ]]; then
  print_step "VS Code 拡張 LaTeX Workshop のインストール"
  if command -v code >/dev/null 2>&1; then
    if ! code --list-extensions | grep -qi '^James-Yu.latex-workshop$'; then
      code --install-extension James-Yu.latex-workshop
      print "LaTeX Workshop をインストールしました。"
    else
      print "LaTeX Workshop は既にインストール済みです。"
    fi
  else
    print "code コマンドが見つかりません。VS Code が未導入か、PATH 未設定です。"
    print "VS Code を使う場合は、Command Palette で『Shell Command: Install “code” command in PATH』を実行してください。"
  fi
fi

print_step "完了"
print "新しいシェルで設定を読み直してください（あなたの環境なら rr でも可）。"
