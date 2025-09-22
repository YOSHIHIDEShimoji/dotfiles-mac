#!/bin/zsh
# ~/dotfiles-mac/scripts/openai_urls.sh
# 1ウィンドウに7タブを開く（Chromeの Default プロファイル固定）

PROFILE="Default"

urls=(
  "https://chatgpt.com"
  "https://gemini.google.com/app"
  "https://aistudio.google.com/app/prompts/new_chat"
  "https://claude.ai/new"
  "https://copilot.microsoft.com"
  "https://perplexity.ai/?login-source=floatingSignup"
  "chrome-extension://iaakpnchhognanibcahlpcplchdfmgma/app.html#/"
)

# 1) 最初のURLを Default プロファイルで新規ウィンドウ起動
open -na "Google Chrome" --args --profile-directory="$PROFILE" --new-window "${urls[1]}"

# 2) Chrome のウィンドウが出るまで待機（最大5秒）
tries=0
while ! /usr/bin/osascript -e 'tell application "Google Chrome" to (count of windows) > 0' >/dev/null 2>&1; do
  ((tries++))
  (( tries > 50 )) && { print -u2 "Chromeのウィンドウを検出できませんでした。"; exit 1; }
  sleep 0.1
done

# 3) 残りURLを同じウィンドウにタブで追加
for ((i=2; i<=${#urls[@]}; i++)); do
  /usr/bin/osascript - "${urls[$i]}" <<'APPLESCRIPT'
on run argv
  set theURL to item 1 of argv
  tell application "Google Chrome"
    if (count of windows) = 0 then make new window
    tell window 1 to make new tab with properties {URL:theURL}
  end tell
end run
APPLESCRIPT
done
