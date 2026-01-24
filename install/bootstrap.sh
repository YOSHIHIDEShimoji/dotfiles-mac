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

# LaunchAgents の自動リンク処理
LAUNCH_SRC="$DOTFILES_DIR/LaunchAgents"
LAUNCH_DST="${HOME}/Library/LaunchAgents"

if [ -d "$LAUNCH_SRC" ]; then
	echo "Setting up LaunchAgents..."
	mkdir -p "$LAUNCH_DST"

	# *.plist が一つもない場合の対策
	shopt -s nullglob
	
	for plist in "$LAUNCH_SRC"/*.plist; do
		filename=$(basename "$plist")
		target="$LAUNCH_DST/$filename"

		# リンク作成
		echo "Linking LaunchAgent: $filename"
		ln -sfv "$plist" "$target"

		# 新しいMacで実行した場合など、未ロードならロードする
		if ! launchctl list | grep -q "${filename%.plist}"; then
			echo "  -> Loading $filename"
			launchctl load "$target" 2>/dev/null || true
		fi
	done
	shopt -u nullglob
fi

# pmset をパスワードなしで実行するための設定
SUDOERS_FILE="/private/etc/sudoers.d/lowpowermode"
if [ ! -f "$SUDOERS_FILE" ]; then
	echo "Setting up passwordless pmset..."
	# sudoの認証をキャッシュ更新（必要ならここでパスワードを聞かれる）
	sudo -v
	echo "${USER} ALL=(ALL) NOPASSWD: /usr/bin/pmset" | sudo tee "$SUDOERS_FILE" > /dev/null
	# sudoersファイルの権限は440にするのが鉄則
	sudo chmod 440 "$SUDOERS_FILE"
else
	echo "pmset sudoers rule already exists. Skipping."
fi

echo "Linking dotfiles..."

# 必要なディレクトリを用意
mkdir -p "${HOME}/.config/karabiner"

# シンボリックリンクを作成
link_from_prop zsh
link_from_prop git
link_from_prop karabiner

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
