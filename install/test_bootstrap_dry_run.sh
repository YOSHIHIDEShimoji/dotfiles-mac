#!/usr/bin/env bash
# bootstrap.sh のドライ実行テスト
# 副作用なし（ln/sudo/launchctl/brew bundle/mv/rm は一切実行しない）

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

PASS=0
FAIL=0
WARN=0

pass() { echo "[PASS] $*"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $*"; FAIL=$((FAIL + 1)); }
warn() { echo "[WARN] $*"; WARN=$((WARN + 1)); }

echo "=== bootstrap.sh ドライ実行テスト ==="
echo "DOTFILES_DIR: $DOTFILES_DIR"
echo ""

# ==========================================
# 1. 必須コマンド確認
# ==========================================
echo "--- [1] 必須コマンド ---"
for cmd in ln mkdir envsubst launchctl plutil awk xargs; do
	if command -v "$cmd" &>/dev/null; then
		pass "コマンド存在: $cmd"
	else
		fail "コマンドが見つからない: $cmd"
	fi
done
echo ""

# ==========================================
# 2. LaunchAgents plist
# ==========================================
echo "--- [2] LaunchAgents plist ---"
LAUNCH_SRC="$DOTFILES_DIR/LaunchAgents"
if [ -d "$LAUNCH_SRC" ]; then
	shopt -s nullglob
	plist_files=("$LAUNCH_SRC"/*.plist)
	shopt -u nullglob
	if [ "${#plist_files[@]}" -eq 0 ]; then
		warn "LaunchAgents ディレクトリは存在するが plist ファイルがない"
	else
		for plist in "${plist_files[@]}"; do
			if plutil -lint "$plist" &>/dev/null; then
				pass "plist 構文OK: $(basename "$plist")"
			else
				fail "plist 構文エラー: $(basename "$plist")"
				plutil -lint "$plist" 2>&1 | sed 's/^/  /'
			fi
		done
	fi
else
	warn "LaunchAgents ディレクトリが存在しない: $LAUNCH_SRC"
fi
echo ""

# ==========================================
# 3-6. links.prop パース・ファイル存在・親ディレクトリ・衝突チェック
# ==========================================
check_links_prop() {
	local dir="$1"
	local prop="$DOTFILES_DIR/$dir/links.prop"

	echo "--- [$dir/links.prop] ---"

	if [ ! -f "$prop" ]; then
		fail "links.prop が存在しない: $prop"
		echo ""
		return
	fi
	pass "links.prop 存在: $prop"

	while IFS= read -r line; do
		[[ -z "$line" || "$line" =~ ^# ]] && continue

		src=$(echo "$line" | awk -F'->' '{print $1}' | xargs)
		dst=$(echo "$line" | awk -F'->' '{print $2}' | xargs | envsubst)

		if [ -z "$src" ]; then
			fail "src が空: $line"
			continue
		fi
		if [ -z "$dst" ]; then
			fail "dst が空（envsubst 展開後）: $line"
			continue
		fi

		src_path="$DOTFILES_DIR/$dir/$src"

		# テスト4: ソースファイル存在
		if [ -e "$src_path" ]; then
			pass "ソースファイル存在: $src_path"
		else
			fail "ソースファイルが存在しない: $src_path"
		fi

		# テスト5: リンク先親ディレクトリ
		dst_dir="$(dirname "$dst")"
		if [ -d "$dst_dir" ]; then
			pass "リンク先親ディレクトリ存在: $dst_dir"
		else
			warn "親ディレクトリなし（mkdir -p で作成される）: $dst_dir"
		fi

		# テスト6: 既存ファイル衝突（シンボリックリンクでない通常ファイル）
		if [ -e "$dst" ] && [ ! -L "$dst" ]; then
			warn "既存ファイル衝突（バックアップ対象）: $dst"
		fi

	done < "$prop"
	echo ""
}

echo "--- [3-6] links.prop パース・ソースファイル・親ディレクトリ・衝突 ---"
echo ""
check_links_prop zsh
check_links_prop git
check_links_prop karabiner
check_links_prop vscode
check_links_prop ghostty

# ==========================================
# 7. Brewfile 検証
# ==========================================
echo "--- [7] Brewfile ---"
BREWFILE="$DOTFILES_DIR/install/Brewfile"
if [ -f "$BREWFILE" ]; then
	pass "Brewfile 存在: $BREWFILE"
	if command -v brew &>/dev/null; then
		pass "brew コマンド存在"
		pkg_count=$(brew bundle list --file="$BREWFILE" 2>/dev/null | wc -l | xargs)
		pass "Brewfile パッケージ数: $pkg_count"
	else
		warn "brew が見つからない（新規 Mac ではインストール前の可能性あり）"
	fi
else
	fail "Brewfile が存在しない: $BREWFILE"
fi
echo ""

# ==========================================
# 8. VS Code 拡張機能
# ==========================================
echo "--- [8] VS Code 拡張機能 ---"
EXT_FILE="$DOTFILES_DIR/vscode/extensions.txt"
if [ -f "$EXT_FILE" ]; then
	ext_count=$(wc -l < "$EXT_FILE" | xargs)
	pass "extensions.txt 存在: $EXT_FILE ($ext_count 行)"
else
	fail "extensions.txt が存在しない: $EXT_FILE"
fi

if command -v code &>/dev/null; then
	pass "code コマンド存在"
else
	warn "code コマンドが見つからない（VS Code 未インストールまたは PATH 未設定）"
fi
echo ""

# ==========================================
# サマリー
# ==========================================
echo "========================================"
echo " テスト結果サマリー"
echo "========================================"
printf " PASS: %d\n" "$PASS"
printf " WARN: %d\n" "$WARN"
printf " FAIL: %d\n" "$FAIL"
echo "========================================"

if [ "$FAIL" -gt 0 ]; then
	echo " → FAIL があります。bootstrap.sh 実行前に修正してください。"
	exit 1
else
	echo " → 問題なし。bootstrap.sh を安全に実行できます。"
	exit 0
fi
