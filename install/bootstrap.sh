#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

link_from_prop() {
	dir="$1"
	prop="$DOTFILES_DIR/$dir/links.prop"

	[ -f "$prop" ] || return

	while IFS= read -r line; do
		# 空行・コメントをスキップ
		[[ -z "$line" || "$line" =~ ^# ]] && continue

		# awkで '->' で分割して source と destination を取得
		src=$(echo "$line" | awk -F'->' '{print $1}' | xargs)
		dst=$(echo "$line" | awk -F'->' '{print $2}' | xargs | envsubst)

		src_path="$DOTFILES_DIR/$dir/$src"

		# 既存ファイルがある場合はバックアップ
		if [ -e "$dst" ] && [ ! -L "$dst" ]; then
			echo "Backing up existing $dst to $dst.backup"
			mv "$dst" "$dst.backup"
		fi

		# シンボリックリンク作成
		echo "Linking $src_path -> $dst"
		ln -sfv "$src_path" "$dst"
	done < "$prop"
}

echo "Linking dotfiles..."

# 必要なディレクトリを用意
mkdir -p "${HOME}/.config/karabiner"
mkdir -p "${HOME}/.templates"

# シンボリックリンクを作成
link_from_prop zsh
link_from_prop git
link_from_prop karabiner
link_from_prop templates

echo "Dotfiles linking done."

# Homebrew パッケージのインストール
BREWFILE="$DOTFILES_DIR/install/Brewfile"
if command -v brew &>/dev/null && [ -f "$BREWFILE" ]; then
	echo "Installing packages via Brewfile..."
	brew bundle --file="$BREWFILE"
	echo "Brew installation completed."
else
	echo "Homebrew not found or Brewfile missing. Skipping package install."
fi
