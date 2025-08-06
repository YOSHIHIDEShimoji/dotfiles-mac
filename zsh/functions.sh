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
ghopen () {
	target_path="${1:-.}"
	abs_path=$(cd "$target_path" && pwd)

	# Git リポジトリのルートを取得
	repo_root=$(git -C "$abs_path" rev-parse --show-toplevel 2>/dev/null) || {
		echo "Not in a Git repository"
		return 1
	}

	repo_name=$(basename "$repo_root")

	# 相対パスを安全に計算
	if [[ "$abs_path" == "$repo_root" ]]; then
		rel_path=""
	else
		rel_path="${abs_path#$repo_root/}"
	fi

	branch=$(git -C "$abs_path" symbolic-ref --short HEAD)

	if [[ -n "$rel_path" ]]; then
		url="https://github.com/YOSHIHIDEShimoji/${repo_name}/tree/${branch}/${rel_path}"
	else
		url="https://github.com/YOSHIHIDEShimoji/${repo_name}/tree/${branch}"
	fi

	# 開く処理
	if [[ "$(uname -s)" == "Darwin" ]]; then
		open "$url"
	elif grep -qi microsoft /proc/version 2>/dev/null; then
		explorer.exe "$url"
	else
		xdg-open "$url" || google-chrome "$url" &
	fi
}

# 指定パスに移動して l コマンドを実行
cl () {
	cd "${1:-$HOME}" && l .
}

# ~/.zshrc を再読み込み
rr () {
	source ~/.zshrc
	echo "~/.zshrc@ reloaded (~/.zshrc -> ~/dotfiles-mac/zsh/zshrc)"
}

# コマンド使用統計を表示
zsh_stats () {
	fc -l 1 | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' | grep --color=auto -v "./" | sort -nr | head -n 20 | column -c3 -s " " -t | nl
}

# URLエンコード
omz_urlencode () {
	python3 -c "import sys, urllib.parse; print(urllib.parse.quote(' '.join(sys.argv[1:])))" "$@"
}

# pathをクリップボードにコピー
copypath () {
	local file="${1:-.}"
	[[ $file = /* ]] || file="$PWD/$file"
	print -n "${file:a}" | clipcopy || return 1
	echo ${(%):-"%B${file:a}%b copied to clipboard."}
}

# ファイルをクリップボードにコピー
copyfile () {
	emulate -L zsh
	cat "$1" | clipcopy
}

# ファイルを開くコマンド 
open_command () {
	if [[ "$OSTYPE" == darwin* ]]; then
		open "$@"
	else
		xdg-open "$@" &> /dev/null
	fi
}

# word で開く
word() {
	local filepath="$1"
	[ -z "$filepath" ] && echo "Usage: word [path]" && return 1
	[[ "$filepath" != *.docx ]] && filepath="${filepath}.docx"
	[ ! -f "$filepath" ] && cp ~/.templates/empty.docx "$filepath"
	open -a "Microsoft Word" "$filepath"
}

# excel で開く
excel() {
	local filepath="$1"
	[ -z "$filepath" ] && echo "Usage: excel [path]" && return 1
	[[ "$filepath" != *.xlsx ]] && filepath="${filepath}.xlsx"
	[ ! -f "$filepath" ] && cp ~/.templates/empty.xlsx "$filepath"
	open -a "Microsoft Excel" "$filepath"
}

# powerpoint で開く
powerpoint() {
	local filepath="$1"
	[ -z "$filepath" ] && echo "Usage: powerpoint [path]" && return 1
	[[ "$filepath" != *.pptx ]] && filepath="${filepath}.pptx"
	[ ! -f "$filepath" ] && cp ~/.templates/empty.pptx "$filepath"
	open -a "Microsoft PowerPoint" "$filepath"
}



# web_search from terminal
function web_search() {
  emulate -L zsh

  # define search engine URLS
  typeset -A urls
  urls=(
    $ZSH_WEB_SEARCH_ENGINES
    google          "https://www.google.com/search?q="
    bing            "https://www.bing.com/search?q="
    brave           "https://search.brave.com/search?q="
    yahoo           "https://search.yahoo.com/search?p="
    duckduckgo      "https://www.duckduckgo.com/?q="
    startpage       "https://www.startpage.com/do/search?q="
    yandex          "https://yandex.ru/yandsearch?text="
    github          "https://github.com/search?q="
    baidu           "https://www.baidu.com/s?wd="
    ecosia          "https://www.ecosia.org/search?q="
    goodreads       "https://www.goodreads.com/search?q="
    qwant           "https://www.qwant.com/?q="
    givero          "https://www.givero.com/search?q="
    stackoverflow   "https://stackoverflow.com/search?q="
    wolframalpha    "https://www.wolframalpha.com/input/?i="
    archive         "https://web.archive.org/web/*/"
    scholar         "https://scholar.google.com/scholar?q="
    ask             "https://www.ask.com/web?q="
    youtube         "https://www.youtube.com/results?search_query="
    deepl           "https://www.deepl.com/translator#auto/auto/"
    dockerhub       "https://hub.docker.com/search?q="
    gems            "https://rubygems.org/search?query="
    npmpkg          "https://www.npmjs.com/search?q="
    packagist       "https://packagist.org/?query="
    gopkg           "https://pkg.go.dev/search?m=package&q="
    chatgpt         "https://chatgpt.com/?q="
    grok            "https://grok.com/?q="
    claudeai        "https://claude.ai/new?q="
    reddit          "https://www.reddit.com/search/?q="
    ppai            "https://www.perplexity.ai/search/new?q="
  )

  # check whether the search engine is supported
  if [[ -z "$urls[$1]" ]]; then
    echo "Search engine '$1' not supported."
    return 1
  fi

  # search or go to main page depending on number of arguments passed
  if [[ $# -gt 1 ]]; then
    # if search goes in the query string ==> space as +, otherwise %20
    # see https://stackoverflow.com/questions/1634271/url-encoding-the-space-character-or-20
    local param="-P"
    [[ "$urls[$1]" == *\?*= ]] && param=""

    # build search url:
    # join arguments passed with '+', then append to search engine URL
    url="${urls[$1]}$(omz_urlencode $param ${(s: :)@[2,-1]})"
  else
    # build main page url:
    # split by '/', then rejoin protocol (1) and domain (2) parts with '//'
    url="${(j://:)${(s:/:)urls[$1]}[1,2]}"
  fi

  open_command "$url"
}


alias bing='web_search bing'
alias brs='web_search brave'
alias google='web_search google'
alias yahoo='web_search yahoo'
alias ddg='web_search duckduckgo'
alias sp='web_search startpage'
alias yandex='web_search yandex'
alias github='web_search github'
alias baidu='web_search baidu'
alias ecosia='web_search ecosia'
alias goodreads='web_search goodreads'
alias qwant='web_search qwant'
alias givero='web_search givero'
alias stackoverflow='web_search stackoverflow'
alias wolframalpha='web_search wolframalpha'
alias archive='web_search archive'
alias scholar='web_search scholar'
alias ask='web_search ask'
alias youtube='web_search youtube'
alias deepl='web_search deepl'
alias dockerhub='web_search dockerhub'
alias gems='web_search gems'
alias npmpkg='web_search npmpkg'
alias packagist='web_search packagist'
alias gopkg='web_search gopkg'
alias chatgpt='web_search chatgpt'
alias grok='web_search grok'
alias claudeai='web_search claudeai'
alias reddit='web_search reddit'
alias ppai='web_search ppai'

#add your own !bang searches here
alias wiki='web_search duckduckgo \!w'
alias news='web_search duckduckgo \!n'
alias map='web_search duckduckgo \!m'
alias image='web_search duckduckgo \!i'
alias ducky='web_search duckduckgo \!'

# other search engine aliases
if [[ ${#ZSH_WEB_SEARCH_ENGINES} -gt 0 ]]; then
  typeset -A engines
  engines=($ZSH_WEB_SEARCH_ENGINES)
  for key in ${(k)engines}; do
    alias "$key"="web_search $key"
  done
  unset engines key
fi

# Python プロジェクトの仮想環境をアクティブにする (sakaijun_udemy)
sj() {
	cd ~/python_projects/sakaijun_udemy
	if [[ "$VIRTUAL_ENV" != "" ]]; then
		deactivate
	fi
	source .venv/bin/activate
}