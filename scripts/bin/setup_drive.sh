#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

SRC="/Users/yoshihide/Library/CloudStorage/GoogleDrive-g.y.shimoji@gmail.com"

# MyDriveリンクの作成
if [ -d "$SRC/マイドライブ" ] && [ ! -e ~/MyDrive ]; then
    ln -s "$SRC/マイドライブ" ~/MyDrive
fi

# Google Driveリンクの移動
if [ -L ~/Google\ Drive ]; then
    rm ~/Google\ Drive
fi

# ★これ重要：何があっても最後は「成功」として終わる
exit 0