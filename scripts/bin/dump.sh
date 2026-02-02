#!/usr/bin/env bash

DOTFILES="$HOME/dotfiles-mac"

echo "Syncing environment to dotfiles..."

# Homebrew
if command -v brew &>/dev/null; then
    # dumpした後に、vscode行を除外してBrewfileに保存する
    brew bundle dump --force --file=- | grep -v "^vscode" > "$DOTFILES/install/Brewfile"
    echo "Brewfile updated."
fi

# VS Code 拡張機能
if command -v code &>/dev/null; then
    # 純粋な拡張機能リストをテキストに保存
    code --list-extensions > "$DOTFILES/vscode/extensions.txt"
    echo "VS Code extensions list updated."
fi

# Git Status 確認
cd "$DOTFILES"
if [[ -n $(git status --porcelain) ]]; then
    echo -e "\nChanges detected in dotfiles! Files modified:"
    git status -s
else
    echo -e "\n✨ No changes. Everything is up to date."
fi

# log を残す
{
  echo "--- Logout at $(date) ---"
  bash ~/dotfiles-mac/scripts/bin/dump.sh
} >> ~/.zsh.log 2>&1