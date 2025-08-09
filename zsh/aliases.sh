# ls 系
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# ターミナル便利系
alias h='history'
alias ..='cd ..'
alias ...='cd ../..'

# VSCode
alias v='code .'

#Python
alias py='python3'
alias python='python3'
alias pip='pip3'

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