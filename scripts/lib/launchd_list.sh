#!/bin/bash
# dotfiles-mac/LaunchAgents/ 配下のジョブを HH:MM 形式で一覧表示

set -euo pipefail

PLIST_DIR="${HOME}/dotfiles-mac/LaunchAgents"
PB=/usr/libexec/PlistBuddy

[ -d "$PLIST_DIR" ] || { echo "Not found: $PLIST_DIR" >&2; exit 1; }

shopt -s nullglob
plists=("$PLIST_DIR"/*.plist)
[ ${#plists[@]} -gt 0 ] || { echo "(エージェントなし)"; exit 0; }

fmt_calendar_entry() {
  # 1引数: PlistBuddy の path (例 :StartCalendarInterval / :StartCalendarInterval:0)
  local p="$1" plist="$2"
  local h m wd day mo
  h=$("$PB" -c "Print ${p}:Hour" "$plist" 2>/dev/null || echo "")
  m=$("$PB" -c "Print ${p}:Minute" "$plist" 2>/dev/null || echo "")
  wd=$("$PB" -c "Print ${p}:Weekday" "$plist" 2>/dev/null || echo "")
  day=$("$PB" -c "Print ${p}:Day" "$plist" 2>/dev/null || echo "")
  mo=$("$PB" -c "Print ${p}:Month" "$plist" 2>/dev/null || echo "")

  local hh mm
  hh=$([ -n "$h" ] && printf '%02d' "$h" || echo "**")
  mm=$([ -n "$m" ] && printf '%02d' "$m" || echo "**")

  local prefix=""
  [ -n "$mo" ] && prefix+="M${mo} "
  [ -n "$day" ] && prefix+="D${day} "
  if [ -n "$wd" ]; then
    local names=(Sun Mon Tue Wed Thu Fri Sat)
    prefix+="${names[$wd]} "
  fi
  echo "${prefix}${hh}:${mm}"
}

format_schedule() {
  local plist="$1"

  if "$PB" -c "Print :StartCalendarInterval" "$plist" &>/dev/null; then
    if "$PB" -c "Print :StartCalendarInterval:0" "$plist" &>/dev/null; then
      local i=0 entries=()
      while "$PB" -c "Print :StartCalendarInterval:$i" "$plist" &>/dev/null; do
        entries+=("$(fmt_calendar_entry ":StartCalendarInterval:$i" "$plist")")
        i=$((i+1))
      done
      (IFS=,; echo "${entries[*]}")
    else
      fmt_calendar_entry ":StartCalendarInterval" "$plist"
    fi
    return
  fi

  if sec=$("$PB" -c "Print :StartInterval" "$plist" 2>/dev/null); then
    if [ "$sec" -ge 3600 ] && [ $((sec % 3600)) -eq 0 ]; then
      echo "Every ${sec}s ($((sec/3600))h)"
    elif [ "$sec" -ge 60 ] && [ $((sec % 60)) -eq 0 ]; then
      echo "Every ${sec}s ($((sec/60))m)"
    else
      echo "Every ${sec}s"
    fi
    return
  fi

  if rl=$("$PB" -c "Print :RunAtLoad" "$plist" 2>/dev/null) && [ "$rl" = "true" ]; then
    echo "AtLogin"
    return
  fi

  echo "?"
}

agent_status() {
  # ロード状況: PID または last_exit、未ロードは "-"
  local label="$1"
  local line
  line=$(launchctl list 2>/dev/null | awk -v l="$label" '$3 == l {print $1"/"$2; exit}')
  echo "${line:-not-loaded}"
}

{
  echo "LABEL│SCHEDULE│STATUS│PROGRAM"
  for plist in "${plists[@]}"; do
    label=$("$PB" -c "Print :Label" "$plist" 2>/dev/null || basename "$plist" .plist)
    program=$("$PB" -c "Print :ProgramArguments:0" "$plist" 2>/dev/null || echo "?")
    program="${program/#$HOME/\~}"
    sched=$(format_schedule "$plist")
    status=$(agent_status "$label")
    echo "${label}│${sched}│${status}│${program}"
  done
} | column -t -s '│'
