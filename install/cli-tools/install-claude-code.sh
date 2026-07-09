#!/usr/bin/env bash
# Claude Code 本体のインストールのみを責務とする。
# - PATH（$HOME/.local/bin）は zsh/exports.sh が正（追跡ファイルへの追記はしない = #15）。
# - skills 配線（~/.claude/skills -> ~/.agents/skills）は bootstrap.sh が
#   単一シンボリックリンクで行う。ここでは触らない（旧・個別リンクループは廃止 = #14）。
set -euo pipefail

# 現在のターミナルに .local/bin を通す（この後の claude 実行のため。恒久設定は exports.sh）
export PATH="$HOME/.local/bin:$PATH"

# インストール実行
curl -fsSL https://claude.ai/install.sh | bash

echo "done. (skills の配線は bootstrap.sh が担当します)"
