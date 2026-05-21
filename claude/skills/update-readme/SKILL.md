---
name: update-readme
description: dotfiles の README を実際のコードと一致するよう確認・更新するスキル。ファイルを編集した後に「READMEを更新して」「READMEを確認して」と言ったとき、または dotfiles に変更を加えた後に自動的に使用する。
---

# update-readme

dotfiles の変更内容と README の記述が一致しているかを確認し、必要な箇所を更新するワークフロー。

## 前提

- `~/dotfiles-mac/README.md` — macOS 版（main ブランチ）
- `~/dotfiles-linux/README.md` — Linux/WSL 版（linux ブランチ）
- 編集されたファイルに応じて対象 README を判断する

## ワークフロー

### Step 1: 変更ファイルの特定

どのファイルが変更されたかを確認する：

```bash
# mac 側の変更
git -C ~/dotfiles-mac diff --name-only HEAD

# linux 側の変更
git -C ~/dotfiles-linux diff --name-only HEAD
```

### Step 2: README との照合

変更ファイルに応じて README の該当セクションを確認する：

| 変更ファイル | 確認する README セクション |
|------------|--------------------------|
| `zsh/functions/*` が追加 | カスタム関数テーブル |
| `zsh/functions/*` が削除 | カスタム関数テーブル |
| `zsh/aliases.sh` | Zshエイリアスセクション |
| `install/bootstrap-linux.sh` | bootstrap-linux.sh の仕組みセクション |
| `install/bootstrap.sh` | bootstrap.sh の仕組みセクション |
| `vscode/extensions.txt` | VS Code設定セクション |
| `install/Brewfile` | インストールされるアプリセクション |
| `ghostty/` | Ghostty設定セクション |

### Step 2.5: `--help` との照合

CLIスクリプトが存在する場合、`--help` 出力と README のコマンド例を照合する：

```bash
python <script>.py --help
# または
<command> --help
```

確認ポイント：
- **オプション名・フラグ** — README に載っているオプションが実際に存在するか
- **デフォルト値** — README に書かれたデフォルト値と `--help` が一致するか
- **サブコマンド** — README に載っているサブコマンドが実装されているか
- **削除されたオプション** — README には残っているが `--help` に出てこないものを削除

### Step 3: 差異の検出と更新

- **追加された関数** → 関数テーブルに行を追加
- **削除された関数** → 関数テーブルから行を削除
- **変更された動作** → 説明文を更新
- **新しいファイル/ディレクトリ** → ディレクトリ構造に追加
- **削除されたファイル** → ディレクトリ構造から削除

### Step 4: 更新内容の報告

README を更新した場合は変更内容を要約してユーザーに報告する。変更が不要だった場合も「README は最新です」と伝える。

## 注意事項

- README の**文体・トーン**を既存に合わせる（日本語、です/ます調）
- Mac 専用の機能を Linux README に追加しない（docs/platform-notes.md 参照）
- Linux README の `update` 関数は「apt パッケージを一括更新（Linux 専用）」と記述する（brew ベースの Mac 版と区別）
- 関数テーブルの説明は簡潔に（1行以内）
