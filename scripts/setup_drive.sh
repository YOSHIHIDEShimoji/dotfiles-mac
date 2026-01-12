#!/bin/bash

SRC="/Users/yoshihide/Library/CloudStorage/GoogleDrive-g.y.shimoji@gmail.com"

# MyDriveリンクの作成（存在しない場合のみ）
[ -d "$SRC/マイドライブ" ] && [ ! -L ~/MyDrive ] && ln -s "$SRC/マイドライブ" ~/MyDrive

# Google Driveリンクの移動
[ -L ~/Google\ Drive ] && rm ~/Google\ Drive

