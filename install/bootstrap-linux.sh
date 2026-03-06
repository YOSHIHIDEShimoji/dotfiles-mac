#!/usr/bin/env bash
# bootstrap-linux.sh
# Linux / WSL 向けセットアップスクリプト
# macOS の bootstrap.sh をベースに、apt 対応・Linux パス構成に書き換えた専用版。
# 前提: デフォルトシェルが zsh に変更済みであること。
# 実行前に: sudo chsh -s $(which zsh) $USER

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# インストール先を即座に command -v で検出できるようにする
export PATH="$HOME/.local/bin:$PATH"

# ─── ヘルパー ───────────────────────────────────────────
info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

# WSL 判定（スクリプト全体で使用）
IS_WSL=false
[[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=true

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
    ca-certificates \
    jq \
    tree \
    ripgrep \
    fd-find \
    fzf \
    bat \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    trash-cli \
    nodejs \
    npm

# tldr（npm 経由）
if ! command -v tldr &>/dev/null; then
    info "tldr をインストールします..."
    sudo npm install -g tldr
fi

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

# ─── 3b. eza のインストール（apt未収録の場合は公式 deb リポジトリを追加）──────
if ! command -v eza &>/dev/null; then
    if apt-cache show eza &>/dev/null 2>&1; then
        sudo apt-get install -y eza
    else
        info "eza を公式リポジトリ経由でインストールします..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
            | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
            | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt-get update -y
        sudo apt-get install -y eza
    fi
fi

# ─── 3c. ghostty のインストール（純 Linux のみ）─────────────────────────────
if [[ "$IS_WSL" == false ]]; then
    if ! command -v ghostty &>/dev/null; then
        info "ghostty をインストールします..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://apt.ghostty.org/gpg.key \
            | sudo gpg --dearmor -o /etc/apt/keyrings/ghostty-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ghostty-archive-keyring.gpg] https://apt.ghostty.org/ any main" \
            | sudo tee /etc/apt/sources.list.d/ghostty.list
        sudo apt-get update -y
        sudo apt-get install -y ghostty
    fi
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

# Ghostty は純 Linux のみリンク（WSL はデスクトップ環境がないため不要）
if [[ "$IS_WSL" == false ]]; then
    link_from_prop ghostty
fi

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
if [ ! -d "$HOME/.pyenv" ]; then
    info "pyenv をインストールします..."
    curl https://pyenv.run | bash
else
    info "pyenv を更新します..."
    git -C "$HOME/.pyenv" pull --ff-only
    git -C "$HOME/.pyenv/plugins/python-build" pull --ff-only 2>/dev/null || true
fi

# ─── 9. VS Code ──────────────────────────────────────────
# 純 Linux: apt でインストールし、拡張機能を一括導入
# WSL:      VS Code は Windows 側にインストールする運用のため apt インストールしない
#           WSL 拡張機能（Remote Development）は Windows の VS Code に手動インストールが必要
#           参考: https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-vscode
EXTFILE="$DOTFILES_DIR/vscode/extensions.txt"

if [[ "$IS_WSL" == false ]]; then
    # 純 Linux: VS Code をインストール
    if ! command -v code &>/dev/null; then
        info "VS Code をインストールします..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
            | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
            | sudo tee /etc/apt/sources.list.d/vscode.list
        sudo apt-get update -y
        sudo apt-get install -y code
    fi
    if [ -f "$EXTFILE" ]; then
        info "VS Code 拡張機能をインストールします..."
        # ms-vscode-remote.vscode-remote-extensionpack は純 Linux では不要のためスキップ
        grep -v '^ms-vscode-remote\.vscode-remote-extensionpack$' "$EXTFILE" \
            | xargs -L 1 code --install-extension
    fi
else
    info "WSL 環境のため VS Code インストールをスキップします。"
    info "Windows 側の VS Code に Remote Development 拡張機能パックをインストールしてください。"
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
echo ""
if [[ "$IS_WSL" == true ]]; then
echo " WSL 向け追加セットアップ（Windows 側で実施）:"
echo ""
echo "   [Nerd Fonts] starship のアイコンを正しく表示するために必須"
echo "   1. https://www.nerdfonts.com/font-downloads からフォントをDL"
echo "      (CaskaydiaCove / FiraCode / JetBrainsMono 等)"
echo "   2. .ttf を全選択 → 右クリック → インストール"
echo "   3. Windows Terminal: 設定 → WSL プロファイル → 外観"
echo "      → フォントフェイス → インストールした Nerd Font を選択"
echo ""
echo "   [VS Code] WSL から code コマンドで接続するための設定"
echo "   1. VS Code for Windows をインストール"
echo "      https://code.visualstudio.com/download"
echo "   2. Remote Development 拡張機能パックをインストール"
echo "      ms-vscode-remote.vscode-remote-extensionpack"
echo "   3. WSL ターミナルで 'code .' を実行して接続"
fi
echo "════════════════════════════════════════════════"
