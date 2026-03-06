#!/usr/bin/env bash
# bootstrap-linux.sh
# Linux / WSL 向けセットアップスクリプト
# インストール対象パッケージは install/Aptfile で管理（macOS の Brewfile に相当）

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

# ─── Aptfile 読み込み ────────────────────────────────────
# [common], [linux], [wsl] セクションから対応プラットフォームのパッケージを取得する
get_packages() {
    local target="$1"
    local section="" line
    local aptfile="$DOTFILES_DIR/install/Aptfile"
    [[ -f "$aptfile" ]] || return

    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        if [[ "$line" =~ ^\[([a-z-]+)\]$ ]]; then
            section="${BASH_REMATCH[1]}"
            continue
        fi
        [[ "$section" == "$target" ]] && echo "$line"
    done < "$aptfile"
}

mapfile -t common_pkgs   < <(get_packages "common")
if [[ "$IS_WSL" == true ]]; then
    mapfile -t platform_pkgs < <(get_packages "wsl")
else
    mapfile -t platform_pkgs < <(get_packages "linux")
fi
all_pkgs=("${common_pkgs[@]}" "${platform_pkgs[@]}")

# ─── 1. 特殊リポジトリのセットアップ ────────────────────
# Aptfile に記載されたパッケージのうち公式 apt に含まれないものはリポジトリを事前追加する
info "追加リポジトリを確認します..."
sudo mkdir -p /etc/apt/keyrings

for pkg in "${all_pkgs[@]}"; do
    case "$pkg" in
        eza)
            if ! apt-cache show eza &>/dev/null 2>&1; then
                info "eza: 公式 deb リポジトリを追加します..."
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
                    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
                    | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            fi
            ;;
        ghostty)
            if ! apt-cache show ghostty &>/dev/null 2>&1; then
                info "ghostty: apt.ghostty.org リポジトリを追加します..."
                curl -fsSL https://apt.ghostty.org/gpg.key \
                    | sudo gpg --dearmor -o /etc/apt/keyrings/ghostty-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ghostty-archive-keyring.gpg] https://apt.ghostty.org/ any main" \
                    | sudo tee /etc/apt/sources.list.d/ghostty.list
            fi
            ;;
        code)
            if ! apt-cache show code &>/dev/null 2>&1; then
                info "VS Code: packages.microsoft.com リポジトリを追加します..."
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
                    | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
                    | sudo tee /etc/apt/sources.list.d/vscode.list
            fi
            ;;
        google-chrome-stable)
            if ! apt-cache show google-chrome-stable &>/dev/null 2>&1; then
                info "Google Chrome: dl.google.com リポジトリを追加します..."
                wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
                    | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
                    | sudo tee /etc/apt/sources.list.d/google-chrome.list
            fi
            ;;
    esac
done

# ─── 2. zsh の確認（chsh 前に確保）─────────────────────────
# zsh は [common] に含まれるが、chsh より前に確実に入れる
if ! command -v zsh &>/dev/null; then
    info "zsh が見つかりません。事前にインストールします..."
    sudo apt-get update -y
    sudo apt-get install -y zsh
fi

# ─── 3. デフォルトシェルを zsh に変更 ───────────────────────
ZSH_PATH="$(which zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    info "デフォルトシェルを zsh に変更します: $ZSH_PATH"
    sudo chsh -s "$ZSH_PATH" "$USER"
    warn "シェル変更を反映するには、ログアウトして再ログインしてください。"
else
    info "デフォルトシェルはすでに zsh です。"
fi

# ─── 4. Aptfile のパッケージを一括インストール ────────────────
info "パッケージをインストールします: ${all_pkgs[*]}"
sudo apt-get update -y
sudo apt-get install -y "${all_pkgs[@]}"

# ─── 5. インストール後のシンボリックリンク補完 ───────────────
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

# ─── 6. npm パッケージ ──────────────────────────────────────
if ! command -v tldr &>/dev/null; then
    info "tldr をインストールします..."
    sudo npm install -g tldr
fi

# ─── 7. シンボリックリンクの作成 ─────────────────────────
link_from_prop() {
    dir="$1"
    prop="$DOTFILES_DIR/$dir/links.prop"

    [ -f "$prop" ] || return

    while IFS= read -r line; do
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

# ─── 8. starship のインストール ─────────────────────────────
if ! command -v starship &>/dev/null; then
    info "starship をインストールします..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# ─── 9. zoxide のインストール ───────────────────────────────
if ! command -v zoxide &>/dev/null; then
    info "zoxide をインストールします..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# ─── 10. pyenv のセットアップ ───────────────────────────────
if [ ! -d "$HOME/.pyenv" ]; then
    info "pyenv をインストールします..."
    curl https://pyenv.run | bash
else
    info "pyenv を更新します..."
    git -C "$HOME/.pyenv" pull --ff-only
    git -C "$HOME/.pyenv/plugins/python-build" pull --ff-only 2>/dev/null || true
fi

# ─── 11. VS Code 拡張機能（純 Linux のみ）──────────────────
# 純 Linux: Aptfile の [linux] に code を追加すれば apt でインストール済み
# WSL:      VS Code は Windows 側にインストールする運用のため apt インストールしない
#           参考: https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-vscode
EXTFILE="$DOTFILES_DIR/vscode/extensions.txt"

if [[ "$IS_WSL" == false ]]; then
    if command -v code &>/dev/null && [ -f "$EXTFILE" ]; then
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
