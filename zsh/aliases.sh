# ls
alias l='eza --icons --group-directories-first'
alias ll='eza -l --git --icons --group-directories-first --header'
alias la='eza -la --git --icons --group-directories-first --header'
alias lt='eza --tree'
alias grep='grep --color=auto'

# find
alias f='fd'
alias fh='fd --hidden --exclude .git --exclude node_modules --exclude .venv --exclude .cache'

# dust
alias d='dust -r'

# rg
alias r='rg'

# procs
alias p='procs'

# ターミナル
alias h='history'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'

# 確認
alias rm='trash -v'
alias mv='mv -i'
alias cp='cp -i'

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
alias port='lsof -i -P -n'

# リンク
alias moodle='open -na "Google Chrome" --args --profile-directory="Profile 1" "https://moodle.gs.chiba-u.jp/moodle/my/"'
