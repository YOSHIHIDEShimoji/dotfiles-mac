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

		# awkで正確に '->' で分割
		src=$(echo "$line" | awk -F'->' '{print $1}' | xargs)
		dst=$(echo "$line" | awk -F'->' '{print $2}' | xargs | envsubst)

		src_path="$DOTFILES_DIR/$dir/$src"

		# バックアップ処理
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
link_from_prop zsh
link_from_prop git
echo "Done!"
