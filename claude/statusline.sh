#!/usr/bin/env bash
# ~/.claude/statusline.sh (dotfiles: claude/statusline.sh からシンボリックリンク)
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "?"')
effort=$(echo "$input" | jq -r '.effort.level // empty')
ctx=$(echo "$input" | jq -r '(.context_window.used_percentage // 0) | floor')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // ""' | sed "s|$HOME|~|")

now=$(date +%s)

CYAN=$'\033[1;36m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
GRAY=$'\033[90m'
WHITE=$'\033[1;37m'
RESET=$'\033[0m'

bar() {
  local pct=$1
  local filled=$((pct * 6 / 100))
  local empty=$((6 - filled))
  local out="${GREEN}"
  for _ in $(seq 1 $filled); do out+="▓"; done
  out+="${GRAY}"
  for _ in $(seq 1 $empty);  do out+="░"; done
  out+="${RESET}"
  printf "%s" "$out"
}

human() {
  local s=$1
  local d=$((s / 86400))
  local h=$(((s % 86400) / 3600))
  local m=$(((s % 3600) / 60))
  if   [ "$d" -gt 0 ]; then echo "${d}d${h}h"
  elif [ "$h" -gt 0 ]; then echo "${h}h${m}m"
  else echo "${m}m"
  fi
}

rate_part=""
for win in five_hour seven_day; do
  pct=$(echo "$input" | jq -r ".rate_limits.${win}.used_percentage // empty")
  rst=$(echo "$input" | jq -r ".rate_limits.${win}.resets_at // empty")
  [ -z "$pct" ] && continue
  pct=${pct%.*}
  label=$([ "$win" = "five_hour" ] && echo "5h" || echo "7d")
  [ -n "$rate_part" ] && rate_part+="  "
  rate_part+="${WHITE}${label}${RESET} $(bar "$pct") ${YELLOW}${pct}%${RESET} ${GRAY}$(human $((rst - now)))${RESET}"
done

model_part="${CYAN}${model}${RESET}"
[ -n "$effort" ] && model_part+=" ${GRAY}(${effort})${RESET}"

if [ -n "$rate_part" ]; then
  echo "${model_part} ${GRAY}|${RESET} ${GRAY}ctx:${RESET}${YELLOW}${ctx}%${RESET} ${GRAY}|${RESET} ${rate_part} ${GRAY}|${RESET} ${GRAY}${cwd}${RESET}"
else
  echo "${model_part} ${GRAY}|${RESET} ${GRAY}ctx:${RESET}${YELLOW}${ctx}%${RESET} ${GRAY}|${RESET} ${GRAY}${cwd}${RESET}"
fi
