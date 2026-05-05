#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

PROJECT_DIR="/Users/yoshihide/my-projects/spotify-top50-archiver"
LOG_FILE="$PROJECT_DIR/run.log"

cd "$PROJECT_DIR" || exit 1

{
  echo "----- $(date '+%Y-%m-%d %H:%M:%S') -----"
  "$HOME/.pyenv/shims/python" archive_top50.py
} >> "$LOG_FILE" 2>&1

exit 0
