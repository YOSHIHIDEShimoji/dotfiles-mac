# ディレクトリを作って移動
mkcd() {
	mkdir -p "$1" && cd "$1"
}

# Cファイルをコンパイル＆実行
c() {
	[[ "$1" == *.c ]] || { echo "Usage: c file.c [args ...]"; return 1; }

	src="$(realpath "$1")"
	shift

	dir="$(dirname "$src")"
	name="$(basename "${src%.c}")"

	build_dir="$dir/build"
	mkdir -p "$build_dir"

	out="$build_dir/$name"

	if grep -q '#[[:space:]]*include[[:space:]]*<math\.h>' "$src"; then
		cc "$src" -o "$out" -lm && "$out" "$@"
	else
		cc "$src" -o "$out" && "$out" "$@"
	fi
}

# 現在のブランチを安全に削除する
gbd() {
	if ! git rev-parse --git-dir > /dev/null 2>&1; then
		echo "このディレクトリは Git リポジトリではありません。"
		return 1
	fi

	current_branch=$(git rev-parse --abbrev-ref HEAD)

	if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
		echo "現在のブランチが main のため削除を中止します。"
		return 1
	fi

	echo "ブランチ '$current_branch' を main にチェックアウト後に削除します。よろしいですか？ (y/n)"
	read -r ans
	if [[ "$ans" == [Yy] ]]; then
		git checkout main &&
		git branch -d "$current_branch" || {
			echo "ローカルブランチの削除に失敗しました。"
			echo "マージしてから再度実行して下さい。"
			return 1
		}
		git push origin --delete "$current_branch"
		echo "'$current_branch' を削除しました。"
	else
		echo "キャンセルしました。"
	fi
}

# GitHub 上でカレント（または指定）パスを開く
ghopen() {
	target_path="${1:-.}"
	abs_path=$(realpath "$target_path")

	repo_root=$(git -C "$abs_path" rev-parse --show-toplevel 2>/dev/null) || {
		echo "Not in a Git repository"
		return 1
	}

	repo_name=$(basename "$repo_root")
	rel_path=$(realpath --relative-to="$repo_root" "$abs_path")
	branch=$(git -C "$abs_path" symbolic-ref --short HEAD)

	url="https://github.com/YOSHIHIDEShimoji/${repo_name}/tree/${branch}/${rel_path}"

	if grep -qi microsoft /proc/version; then
		explorer.exe "$url"
	else
		open "$url" 2>/dev/null || google-chrome "$url" &
	fi
}

# Python プロジェクトの仮想環境をアクティブにする (sakaijun_udemy)
function sj() {
	cd ~/python_projects/sakaijun_udemy
	if [[ "$VIRTUAL_ENV" != "" ]]; then
		deactivate
	fi
	source .venv/bin/activate
}