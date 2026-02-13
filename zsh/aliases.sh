# ls
alias l='eza --icons --group-directories-first'
alias ll='eza -l --git --icons --group-directories-first --header'
alias la='eza -la --git --icons --group-directories-first --header'
alias lt='eza --tree'
alias grep='grep --color=auto'

# find
alias fd='fd --hidden --exclude .git' # 隠しファイルも含めるが .git は除外

# dust
alias du='dust -r'
alias df='dust -r -d 1'

# ターミナル
alias h='history'
alias ..='cd ..'
alias ...='cd ../..'
alias o='open .'
alias mkdir='mkdir -p'

# 確認
alias rm='trash -v'
alias mv='mv -i'
alias cp='cp -Ri'

# clear 一発できれいにする
alias clear='clear; clear'

# VS code
alias v='code .'

# git
alias g='git'
alias gs='git status'
alias gco='git checkout'
alias gbr='git branch'
alias gcm='git commit -m'
alias gca='git commit -a -m'
alias glast='git log -1 HEAD'
alias glg='git log --oneline --graph --all --decorate'
alias gdf='git diff'
alias gdfc='git diff --cached'
alias gunstage='git reset HEAD --'
alias gundo='git reset --soft HEAD~1'
alias gpu='git push'
alias gpl='git pull'

# ネットワーク・システム
alias myip='curl ifconfig.me'
alias port='lsof -i -P'

# リンク
alias moodle='open -na "Google Chrome" --args --profile-directory="Profile 1" "https://moodle.gs.chiba-u.jp/moodle/my/"'

# web_search()　のエイリアス
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