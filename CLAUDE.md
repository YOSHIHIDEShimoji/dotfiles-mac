# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## 概要

macOS 用の dotfiles リポジトリ。Zsh、Git、Karabiner-Elements、VS Code、Homebrew の設定を管理しています。すべての設定ファイルは `links.prop` を通じて、このリポジトリからシステム上の所定の場所にシンボリックリンクされます。

## 主要コマンド

- **フルセットアップ**: `cd ~/dotfiles && ./install/bootstrap.sh`
- **Homebrew パッケージのインストール**: `brew bundle --file=~/dotfiles/install/Brewfile`
- **Zsh 設定の再読み込み**: `rr`（カスタム関数、または `source ~/.zshrc`）
- **新しい Zsh 関数の追加**: `zsh/functions/` にファイルを作成（拡張子なし、`autoload -Uz` で自動読み込み）

## アーキテクチャ

### シンボリックリンクシステム (links.prop)

各設定ディレクトリには `links.prop` ファイルがあり、`source -> destination` の形式でシンボリックリンクを定義しています。`bootstrap.sh` がこれを読み取り、既存ファイルをバックアップした上でシンボリックリンクを作成します。

| ディレクトリ | リンク先 |
|-----------|----------|
| `zsh/links.prop` | `~/.zshrc`, `~/.zshenv`, `~/.config/starship.toml` |
| `git/links.prop` | `~/.gitconfig`, `~/.gitignore_global` |
| `karabiner/links.prop` | `~/.config/karabiner/karabiner.json` |
| `vscode/links.prop` | VS Code User `settings.json` |
| `ghostty/links.prop` | `~/Library/Application Support/com.mitchellh.ghostty/config` |

### Zsh の読み込み順序

1. `zshenv` — `ZDOTDIR=~/dotfiles/zsh` を設定（ログイン前に読み込み）
2. `zshrc` — メイン設定、以下の順序で読み込み:
   - `exports.sh` — PATH と環境変数
   - `aliases.sh` — シェルおよび Git のエイリアス
   - `functions/*` — `fpath` 経由で自動読み込み（1ファイル1関数、拡張子なし）
   - `plugins/*` — Homebrewインストール済みプラグイン（zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting）をsource
   - Starshipプロンプト（`starship/current.toml`、`sstyle` でテーマ切替）
   - fzf および zoxide の統合

### スクリプト PATH

`exports.sh` が `scripts/bin` とその配下の実行ディレクトリを PATH に追加します。スクリプトは名前で直接呼び出し可能です（例: `ppdf_unlock`, `yt2ob`）。実行権限の付与は bootstrap 実行時に一度だけ行います（シェル起動ごとの `chmod` は廃止）。ランタイム状態（履歴・補完ダンプ）は `~/.cache/zsh/` に退避し、リポジトリを汚しません。

## 規約

- **言語**: README やコメントは日本語で記述する。同じ規約に従うこと。
- **Zsh 関数**: `zsh/functions/` に1ファイル1関数、ファイル名 = 関数名、拡張子なし。
- **プラグイン**: Homebrewでインストール・管理（zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting）。
- **新しいシンボリックリンク**: 該当する `links.prop` ファイルにエントリを追加。`bootstrap.sh` が残りを処理する。
- **新しい Homebrew パッケージ**: `install/Brewfile` に追加（CLI は `brew "name"`、GUI は `cask "name"`）。
- **Git デフォルトブランチ**: `main`。push 時に自動で upstream を設定（`push.autoSetupRemote = true`）。

---

## クロスプラットフォーム運用（macOS / WSL / 純Linux）

**単一 `main` ブランチで全 OS をカバーする。** 旧・2本ブランチ運用（`linux` ブランチ + `git worktree` + `/sync-to-linux`）は 2026-07-08 に廃止した。共有ファイルは実行時に OS を判定して分岐する。同期作業は不要。

### リポジトリ配置

| 環境 | 配置先 | ブランチ |
|------|--------|---------|
| macOS | `~/dotfiles` | `main` |
| Linux/WSL | `~/dotfiles-linux` | `main` |

配置ディレクトリ名が OS で異なるのは `zsh/zshenv`・`zsh/exports.sh` の `DOTFILES`/`ZDOTDIR` 定義に合わせるため（Linux/WSL では `main` を `~/dotfiles-linux` に clone する）。ブランチはどちらも `main`。

### OS 差異の吸収方法（新規追加・変更時の指針）

大半のファイル（skills・git・tmux・ほとんどの関数/エイリアス）は OS 非依存でそのまま動く。OS で挙動が変わる箇所だけ、次のいずれかで吸収する:

1. **`command -v` ガード** — 「そのツールがあれば使う」型（例: `dump` の `command -v brew`）。判定を書かずに両対応できる。
2. **明示的な `if`** — コマンド自体が違う所だけ:
   ```zsh
   if [[ "$(uname)" == "Darwin" ]]; then
     ...   # macOS: brew / pbcopy / open -a / caffeinate / pmset
   elif [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
     ...   # WSL: clip.exe / powershell.exe / explorer.exe
   else
     ...   # 純Linux: apt / xclip / xdg-open
   fi
   ```
3. **ファイル単位で分離** — OS 固有の「器」は他 OS では触らない:
   - Mac 専用: `ghostty/`・`karabiner/`・`LaunchAgents/`・`install/Brewfile`・`install/bootstrap.sh`・`zsh/functions/awake`(caffeinate)・`lp`(pmset)
   - Linux/WSL 専用: `install/Aptfile`・`install/bootstrap-linux.sh`
   - `bootstrap.sh`(Mac) は karabiner/ghostty/LaunchAgents 等もリンク。`bootstrap-linux.sh`(Linux) は zsh/git/tmux/claude のみリンク（ghostty は純Linuxのみ）。

パッケージ追加は `install/Brewfile`（Mac）と `install/Aptfile`（Linux）の両方に1行ずつ（パッケージ名が OS で違うため不可避）。

### セットアップ

- **macOS**: `cd ~/dotfiles && ./install/bootstrap.sh`
- **Linux/WSL**: `main` を `~/dotfiles-linux` に clone → `bash install/bootstrap-linux.sh`（前提: `chsh -s $(which zsh)` 済み）

### 復元用バックアップ

旧 `linux` ブランチは `backup/linux-20260708` タグ（origin に push 済み）として保全。必要時は `git checkout backup/linux-20260708` で参照可能。
