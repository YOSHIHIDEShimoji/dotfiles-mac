#!/bin/bash
# dotfiles-mac/LaunchAgents/ 配下のジョブを一覧表示
# 列: LABEL / SCHEDULE / NEXT (次回実行) / STATUS / PROGRAM

set -euo pipefail

PLIST_DIR="${HOME}/dotfiles-mac/LaunchAgents"
PB=/usr/libexec/PlistBuddy

[ -d "$PLIST_DIR" ] || { echo "Not found: $PLIST_DIR" >&2; exit 1; }

shopt -s nullglob
plists=("$PLIST_DIR"/*.plist)
[ ${#plists[@]} -gt 0 ] || { echo "(エージェントなし)"; exit 0; }

# ---- スケジュール表示 (HH:MM) ----
fmt_calendar_entry() {
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
  [ -n "$mo" ]  && prefix+="M${mo} "
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

# ---- 次回実行時刻 (epoch を返す) ----
calendar_entry_next_epoch() {
  local p="$1" plist="$2"
  local h m wd
  h=$("$PB" -c "Print ${p}:Hour" "$plist" 2>/dev/null || echo "")
  m=$("$PB" -c "Print ${p}:Minute" "$plist" 2>/dev/null || echo 0)
  wd=$("$PB" -c "Print ${p}:Weekday" "$plist" 2>/dev/null || echo "")

  # Hour 省略 (毎時 Minute 分) は対象外
  [ -z "$h" ] && return

  local today hh mm
  today=$(date +%Y-%m-%d)
  hh=$(printf '%02d' "$h")
  mm=$(printf '%02d' "$m")

  if [ -n "$wd" ]; then
    local cur_wday cur_hm tgt_hm days
    cur_wday=$(date +%w)
    cur_hm=$(date +%H%M)
    tgt_hm=$(printf '%02d%02d' "$h" "$m")
    days=$(( (wd - cur_wday + 7) % 7 ))
    if [ "$days" -eq 0 ] && [ "$cur_hm" -ge "$tgt_hm" ]; then
      days=7
    fi
    date -j -v +"${days}"d -f "%Y-%m-%d %H:%M" "${today} ${hh}:${mm}" +%s 2>/dev/null
  else
    local target now
    target=$(date -j -f "%Y-%m-%d %H:%M" "${today} ${hh}:${mm}" +%s 2>/dev/null) || return
    now=$(date +%s)
    if [ "$target" -gt "$now" ]; then
      echo "$target"
    else
      date -j -v +1d -f "%Y-%m-%d %H:%M" "${today} ${hh}:${mm}" +%s 2>/dev/null
    fi
  fi
}

next_run_epoch() {
  local plist="$1"

  if "$PB" -c "Print :StartCalendarInterval" "$plist" &>/dev/null; then
    if "$PB" -c "Print :StartCalendarInterval:0" "$plist" &>/dev/null; then
      local i=0 best="" e
      while "$PB" -c "Print :StartCalendarInterval:$i" "$plist" &>/dev/null; do
        e=$(calendar_entry_next_epoch ":StartCalendarInterval:$i" "$plist")
        if [ -n "$e" ] && { [ -z "$best" ] || [ "$e" -lt "$best" ]; }; then
          best="$e"
        fi
        i=$((i+1))
      done
      echo "$best"
    else
      calendar_entry_next_epoch ":StartCalendarInterval" "$plist"
    fi
  fi
  # Interval / AtLogin は推定不可 (空文字を返す)
}

fmt_next() {
  local epoch="$1"
  [ -z "$epoch" ] && { echo "—"; return; }

  local now today_start day_off
  now=$(date +%s)
  today_start=$(date -j -f "%Y-%m-%d %H:%M" "$(date +%Y-%m-%d) 00:00" +%s)
  day_off=$(( (epoch - today_start) / 86400 ))

  case "$day_off" in
    0) date -r "$epoch" "+Today %H:%M" ;;
    1) date -r "$epoch" "+Tomorrow %H:%M" ;;
    *) date -r "$epoch" "+%a %m/%d %H:%M" ;;
  esac
}

# ---- ロード状況 ----
agent_status() {
  local label="$1"
  local line pid st
  line=$(launchctl list 2>/dev/null | awk -v l="$label" '$3 == l {print; exit}')
  if [ -z "$line" ]; then
    echo "unloaded"
    return
  fi
  pid=$(echo "$line" | awk '{print $1}')
  st=$(echo  "$line" | awk '{print $2}')
  if [ "$pid" != "-" ]; then
    echo "running($pid)"
  elif [ "$st" = "0" ]; then
    echo "idle"
  else
    echo "fail($st)"
  fi
}

# ---- 出力 ----
{
  echo "LABEL│SCHEDULE│NEXT│STATUS│PROGRAM"
  for plist in "${plists[@]}"; do
    label=$("$PB" -c "Print :Label" "$plist" 2>/dev/null || basename "$plist" .plist)
    program=$("$PB" -c "Print :ProgramArguments:0" "$plist" 2>/dev/null || echo "?")
    case "$program" in "$HOME"/*) program="~${program#$HOME}" ;; esac
    sched=$(format_schedule "$plist")
    next=$(fmt_next "$(next_run_epoch "$plist")")
    status=$(agent_status "$label")
    echo "${label}│${sched}│${next}│${status}│${program}"
  done
} | column -t -s '│'

cat <<'LEGEND'

凡例:
  STATUS  idle=待機(直近 exit 0) / running(PID)=実行中 / fail(N)=直近 exit N / unloaded=未ロード
  NEXT    Calendar のみ算出。Interval/AtLogin は推定不可のため "—"
LEGEND
