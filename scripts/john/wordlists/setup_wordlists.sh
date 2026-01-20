#!/bin/bash

# スクリプト自身が置かれているディレクトリ（wordlists/）に移動
cd "$(dirname "$0")"

# 2. rockyou.txt がなければダウンロードして解凍
if [ ! -f "rockyou.txt" ]; then
    echo "Downloading rockyou.txt..."
    curl -L https://github.com/zacheller/rockyou/raw/master/rockyou.txt.tar.gz -o rockyou.txt.tar.gz
    tar -xzvf rockyou.txt.tar.gz
    rm rockyou.txt.tar.gz
    echo "Done!"
else
    echo "rockyou.txt already exists."
fi