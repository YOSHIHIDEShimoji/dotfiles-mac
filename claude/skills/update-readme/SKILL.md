---
name: update-readme
description: dotfiles の README を実際のコードと一致するよう確認・更新するスキル。ファイルを編集した後に「READMEを更新して」「READMEを確認して」と言ったとき、または dotfiles に変更を加えた後に自動的に使用する。
---

# update-readme

dotfiles の変更内容と README の記述が一致しているかを確認し、必要な箇所を更新するワークフロー。

## 前提

- README は `~/dotfiles/README.md` の**1本のみ**（macOS 専用の dotfiles）
- セクション名は変わることがある。照合前に `grep -n "^## \|^### " README.md` で**実際の見出し一覧を取得**し、下の表とズレていたら実物を正とする

## ワークフロー

### Step 1: 変更ファイルの特定

どのファイルが変更されたかを確認する：

```bash
git -C ~/dotfiles diff --name-only HEAD
```

### Step 2: README との照合

変更ファイルに応じて README の該当セクションを確認する：

| 変更ファイル | 確認する README セクション |
|------------|--------------------------|
| `zsh/functions/*` の追加・削除 | 「主な機能 > Zshカスタム関数」テーブル |
| `scripts/` 配下 | 「スクリプト群 (scripts/)」 |
| `install/bootstrap.sh` | 「bootstrap.sh の仕組み」「クイックスタート」 |
| `install/test_bootstrap_dry_run.sh`・`.github/workflows/` | 「テスト / CI」 |
| `install/Brewfile` | 「カスタマイズ > Brewfileの編集」 |
| `vscode/*` | 「VS Code設定」（extensions.txt は「ディレクトリ構造」の拡張機能数も更新: `wc -l < vscode/extensions.txt`） |
| `LaunchAgents/` | 「LaunchAgents」 |
| `ghostty/`・`karabiner/` | 「主な機能 > キーバインド」＋ `docs/keybindings.md` |
| `ssh/`・`tmux/`・`claude/` | 「SSH設定」「tmux設定」「Claude Code / AI Agent設定」 |
| ファイル・ディレクトリの新設/削除 | 「ディレクトリ構造」ツリー |

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
- 関数テーブルの説明は簡潔に（1行以内）
- README に書いた数値・コマンド例は**実物と照合してから**書く（例: 拡張機能数は `wc -l`、関数の説明は実装を読む）。記憶で書かない
