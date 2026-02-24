#!/bin/bash

DOTFILES_DIR="${DOTFILES:-$HOME/dotfiles-mac}"
WORDLISTS_DIR="$DOTFILES_DIR/scripts/john/wordlists"

mkdir -p "$WORDLISTS_DIR"

if [ ! -f "$WORDLISTS_DIR/rockyou.txt" ]; then
    echo "Downloading rockyou.txt..."
    curl -L https://github.com/zacheller/rockyou/raw/master/rockyou.txt.tar.gz -o "$WORDLISTS_DIR/rockyou.txt.tar.gz"
    tar -xzvf "$WORDLISTS_DIR/rockyou.txt.tar.gz" -C "$WORDLISTS_DIR"
    rm "$WORDLISTS_DIR/rockyou.txt.tar.gz"
    echo "Done!"
else
    echo "rockyou.txt already exists."
fi
