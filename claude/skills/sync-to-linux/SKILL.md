---
name: sync-to-linux
description: dotfiles-mac（main ブランチ）と dotfiles-linux（linux ブランチ）の差分を比較し、main 側の変更を linux に移植するスキル。ユーザーが `/sync-to-linux` を呼び出したとき、または「linuxに同期して」「linux側に反映して」と言ったときに使用する。docs/platform-notes.md の除外ルールを参照して Mac専用の変更をスキップし、移植対象の変更を linux ブランチの対応ファイルに適用する。
---

# sync-to-linux

dotfiles-mac（main）→ dotfiles-linux（linux）への変更移植ワークフロー。

## 前提

- `~/dotfiles-mac` = main ブランチ（macOS 環境）
- `~/.dotfiles-linux` = linux ブランチ（Linux/WSL 環境）、git worktree で物理配置
- `~/dotfiles-mac/docs/platform-notes.md` = Mac専用/Linux専用の移植ルール定義ファイル

## ワークフロー

### Step 1: 差分取得

**コミット単位ではなく、2ブランチ間のファイル差分を比較する。** main が linux より進んでいる前提で、linux に存在しない変更をすべて検出する。

```bash
# 差分のあるファイル一覧
git -C ~/dotfiles-mac diff --name-only linux main

# 特定ファイルの差分内容
git -C ~/dotfiles-mac diff linux main -- <filepath>
```

差分ファイルの一覧を取得したうえで、移植対象になりうるファイルのみ内容を確認する（Mac専用ディレクトリは内容確認不要）。

### Step 2: platform-notes.md の参照

`~/dotfiles-mac/docs/platform-notes.md` を読み込み、以下を判定する：

- **「Mac専用 — Linux/WSL には移植しない」セクション**に該当するファイル・機能は除外
- **「Linux/WSL専用 — Mac には移植しない」セクション**は linux 側で個別に管理
- **「クロスプラットフォーム対応」セクション**に該当するものは OS 判定付きで移植

### Step 3: 移植対象の分類

差分をスキャンして各変更を以下の3つに分類する：

| 分類 | 対応 |
|------|------|
| **移植可能** | dotfiles-linux の対応ファイルに適用 |
| **Mac専用** | スキップ（platform-notes.md に記載済みか確認） |
| **要OS判定** | if 文でラップして移植 |

### Step 4: ユーザーへの報告と確認

変更の分類結果をユーザーに報告する。**必ず各変更について以下の選択肢を提示する：**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
変更内容: [ファイル名] - [変更の概要]

A) dotfiles-linux に即時反映する
B) platform-notes.md に「Mac専用」として記録する（移植しない）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**全変更を一括で確認するかどうかも尋ねる。**

### Step 5: 変更の適用

ユーザーが「A) 即時反映」を選択した変更を dotfiles-linux に適用する：

1. `~/.dotfiles-linux` の対応ファイルを Read で確認
2. 差分を Edit ツールで適用（OS 判定が必要な場合は if 文でラップ）
3. 適用後の変更内容をユーザーに確認

ユーザーが「B) Mac専用として記録」を選択した場合は：
- `~/dotfiles-mac/docs/platform-notes.md` の「Mac専用」セクションに追記

### Step 6: コミット確認

全変更の適用が完了したら、コミット内容をユーザーに提示する。**コミット・プッシュは必ずユーザーの確認を得てから実行する。**

```bash
# dotfiles-linux でコミット
git -C ~/.dotfiles-linux add -A
git -C ~/.dotfiles-linux commit -m "sync: [変更の概要]"
# push はユーザーに確認後
git -C ~/.dotfiles-linux push
```

## ファイルパスの対応表

| macOS (main) | Linux (linux) |
|--------------|---------------|
| `zsh/zshrc` | `zsh/zshrc` |
| `zsh/exports.sh` | `zsh/exports.sh` |
| `zsh/aliases.sh` | `zsh/aliases.sh` |
| `zsh/functions/*` | `zsh/functions/*`（Mac専用を除く） |
| `git/gitconfig` | `git/gitconfig` |
| `git/gitignore_global` | `git/gitignore_global` |
| `vscode/settings.json` | `vscode/settings.json` |
| `vscode/extensions.txt` | `vscode/extensions.txt` |
| `install/bootstrap-linux.sh` | `install/bootstrap-linux.sh` |
| `docs/platform-notes.md` | `docs/platform-notes.md` |
| `scripts/ppdf/*` | `scripts/ppdf/*` |
| `scripts/bin/*` | `scripts/bin/*` |

**移植しないファイル（Mac専用）:**
- `ghostty/` — macOS ターミナルアプリ固有
- `karabiner/` — macOS キーリマップツール固有
- `LaunchAgents/` — macOS launchd 固有
- `install/bootstrap.sh` — Homebrew 依存
- `install/Brewfile` — Homebrew 固有
- `scripts/bookmark/` — `open -na "Google Chrome"` macOS 固有
- `zsh/functions/awake` — `caffeinate` macOS 固有
- `zsh/functions/lp` — `pmset` macOS 固有
- `zsh/functions/dump` — `brew bundle` 依存
- `zsh/functions/o` — macOS の `open` 依存（Linux では `xdg-open` を別途定義）

**Linux 側で独自実装済み（Mac版で上書きしない）:**
- `zsh/functions/update` — Linux 版は `apt` ベース、Mac 版は `brew` ベース。差分があっても linux 側の実装を保持する。

**WSLにのみ移植（純Linuxには不要）:**
- `zsh/functions/word` — WSL 環境では Windows の Word を起動できる
- `zsh/functions/excel` — WSL 環境では Windows の Excel を起動できる
- `zsh/functions/powerpoint` — WSL 環境では Windows の PowerPoint を起動できる

## 注意事項

- Mac の現環境（~/dotfiles-mac）は**絶対に壊さない**。linux 側のみ変更する。
- 判断に迷う変更は必ずユーザーに確認する。
- OS 判定コードのパターン:
  ```zsh
  if [[ "$(uname)" == "Darwin" ]]; then
    # Mac 固有
  elif [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    # WSL 固有
  else
    # 純 Linux
  fi
  ```
