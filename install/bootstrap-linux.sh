#!/usr/bin/env bash
# bootstrap-linux.sh
# Linux / WSL 向けセットアップスクリプト
# macOS の bootstrap.sh をベースに、apt 対応・Linux パス構成に書き換えた専用版。
# 前提: デフォルトシェルが zsh に変更済みであること。
# 実行前に: sudo chsh -s $(which zsh) $USER

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# ─── ヘルパー ───────────────────────────────────────────
info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

# ─── 1. zsh のインストール確認 ───────────────────────────
info "zsh の確認..."
if ! command -v zsh &>/dev/null; then
    info "zsh が見つかりません。インストールします..."
    sudo apt-get update -y
    sudo apt-get install -y zsh
fi

# ─── 2. デフォルトシェルを zsh に変更 ─────────────────────
ZSH_PATH="$(which zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    info "デフォルトシェルを zsh に変更します: $ZSH_PATH"
    sudo chsh -s "$ZSH_PATH" "$USER"
    warn "シェル変更を反映するには、ログアウトして再ログインしてください。"
else
    info "デフォルトシェルはすでに zsh です。"
fi

# ─── 3. 必須パッケージのインストール ────────────────────────
info "必須パッケージをインストールします..."
sudo apt-get update -y
sudo apt-get install -y \
    git \
    curl \
    wget \
    jq \
    tree \
    ripgrep \
    fd-find \
    fzf \
    bat \
    eza \
    zoxide \
    starship \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    pyenv \
    nodejs \
    npm

# fd は fd-find としてインストールされるため、fd としてリンクを張る
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    info "fd -> fdfind のシンボリックリンクを作成しました。"
fi

# bat は batcat としてインストールされる場合あり
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    info "bat -> batcat のシンボリックリンクを作成しました。"
fi

# ─── 4. シンボリックリンクの作成 ─────────────────────────
link_from_prop() {
    dir="$1"
    prop="$DOTFILES_DIR/$dir/links.prop"

    [ -f "$prop" ] || return

    while IFS= read -r line; do
        # 空行・コメントをスキップ
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        src=$(echo "$line" | awk -F'->' '{print $1}' | xargs)
        dst=$(echo "$line" | awk -F'->' '{print $2}' | xargs | envsubst)

        [ -n "$dst" ] || { echo "Invalid dst in $prop: $line" >&2; continue; }
        [ -n "$src" ] || { echo "Invalid src in $prop: $line" >&2; continue; }

        src_path="$DOTFILES_DIR/$dir/$src"

        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            info "既存ファイルをバックアップ: $dst -> $dst.backup"
            mv "$dst" "$dst.backup"
        fi

        mkdir -p "$(dirname "$dst")"
        info "リンク作成: $src_path -> $dst"
        ln -sfv "$src_path" "$dst"
    done < "$prop"
}

info "シンボリックリンクを作成します..."
link_from_prop zsh
link_from_prop git

# ─── 5. zshenv のリンク（ZDOTDIR の設定）─────────────────
# dotfiles-linux に clone した場合にパスが変わるため上書き
ZSHENV_PATH="$HOME/.zshenv"
ZSHENV_CONTENT='export ZDOTDIR="$HOME/dotfiles-linux/zsh"'

if [ -f "$ZSHENV_PATH" ]; then
    current=$(cat "$ZSHENV_PATH")
    if [ "$current" != "$ZSHENV_CONTENT" ]; then
        info "既存の .zshenv をバックアップ..."
        cp "$ZSHENV_PATH" "${ZSHENV_PATH}.backup"
    fi
fi
echo "$ZSHENV_CONTENT" > "$ZSHENV_PATH"
info ".zshenv を設定しました: ZDOTDIR=$HOME/dotfiles-linux/zsh"

# ─── 6. starship の設定 ──────────────────────────────────
if ! command -v starship &>/dev/null; then
    info "starship を手動インストールします..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# ─── 7. zoxide のインストール確認 ────────────────────────
if ! command -v zoxide &>/dev/null; then
    info "zoxide を手動インストールします..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# ─── 8. pyenv のセットアップ ─────────────────────────────
if ! command -v pyenv &>/dev/null; then
    info "pyenv を手動インストールします..."
    curl https://pyenv.run | bash
fi

# ─── 9. VSCode 拡張機能（オプション）─────────────────────
if command -v code &>/dev/null; then
    EXTFILE="$DOTFILES_DIR/vscode/extensions.txt"
    if [ -f "$EXTFILE" ]; then
        info "VS Code 拡張機能をインストールします..."
        xargs -L 1 code --install-extension < "$EXTFILE"
    fi
else
    info "code コマンドが見つかりません。VS Code 拡張機能のインストールをスキップします。"
fi

# ─── 完了 ──────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════"
echo " セットアップ完了"
echo "════════════════════════════════════════════════"
echo " 次のステップ:"
echo "   1. ログアウトして再ログイン（シェル変更を反映）"
echo "   2. zsh を起動して設定を確認"
echo ""
echo " オプション（必要に応じて）:"
echo "   bash install/cli-tools/install-claude-code.sh  # Claude Code"
echo "   bash install/cli-tools/install-gemini-cli.sh   # Gemini CLI"
echo "════════════════════════════════════════════════"
