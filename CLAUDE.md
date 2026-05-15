# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## 概要

macOS 用の dotfiles リポジトリ。Zsh、Git、Karabiner-Elements、VS Code、Homebrew の設定を管理しています。すべての設定ファイルは `links.prop` を通じて、このリポジトリからシステム上の所定の場所にシンボリックリンクされます。

## 主要コマンド

- **フルセットアップ**: `cd ~/dotfiles-mac && ./install/bootstrap.sh`
- **Homebrew パッケージのインストール**: `brew bundle --file=~/dotfiles-mac/install/Brewfile`
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

1. `zshenv` — `ZDOTDIR=~/dotfiles-mac/zsh` を設定（ログイン前に読み込み）
2. `zshrc` — メイン設定、以下の順序で読み込み:
   - `exports.sh` — PATH と環境変数
   - `aliases.sh` — シェルおよび Git のエイリアス
   - `functions/*` — `fpath` 経由で自動読み込み（1ファイル1関数、拡張子なし）
   - `plugins/*` — Homebrewインストール済みプラグイン（zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting）をsource
   - Starshipプロンプト（`starship.toml`）
   - fzf および zoxide の統合

### スクリプト PATH

`exports.sh` が `~/dotfiles-mac/scripts/` とそのすべてのサブディレクトリを PATH に追加し、実行権限を付与します。スクリプトは名前で直接呼び出し可能です（例: `ppdf_unlock`, `setup_drive.sh`）。

## 規約

- **言語**: README やコメントは日本語で記述する。同じ規約に従うこと。
- **Zsh 関数**: `zsh/functions/` に1ファイル1関数、ファイル名 = 関数名、拡張子なし。
- **プラグイン**: Homebrewでインストール・管理（zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting）。
- **新しいシンボリックリンク**: 該当する `links.prop` ファイルにエントリを追加。`bootstrap.sh` が残りを処理する。
- **新しい Homebrew パッケージ**: `install/Brewfile` に追加（CLI は `brew "name"`、GUI は `cask "name"`）。
- **Git デフォルトブランチ**: `main`。push 時に自動で upstream を設定（`push.autoSetupRemote = true`）。

---

## クロスプラットフォーム運用（Linux/WSL対応）

### リポジトリ・ブランチ構成

| 環境 | 配置先 | ブランチ |
|------|--------|---------|
| macOS | `~/dotfiles-mac` | `main` |
| Linux/WSL | `~/dotfiles-linux` | `linux` |

`git worktree` で物理的に分離済み。ブランチ切り替えは不要。

- macOS 上での linux ブランチ worktree: `~/.dotfiles-linux`（隠しディレクトリ）
- Linux/WSL 上での main ブランチ worktree: `~/.dotfiles-mac`（隠しディレクトリ）

### 移植ルール

`docs/platform-notes.md` が移植の除外ルールを定義している。
変更が Mac 専用かどうか迷ったら、必ずこのファイルを参照すること。

**基本方針:**
- macOS 固有の機能（`caffeinate`, `pmset`, `open -a`, Homebrew 等）は Linux に移植しない
- `ghostty/`, `karabiner/`, `LaunchAgents/`, `scripts/bookmark/` はMac専用ディレクトリ
- `word`/`excel`/`powerpoint` 関数は WSL にのみ移植（純 Linux には不要）
- OS 差異は `if [[ "$(uname)" == "Darwin" ]]; then ... elif [[ -n "$WSL_DISTRO_NAME" ]]; then ... else ... fi` で吸収

### Linux/WSLへの同期

Mac で機能を追加・変更したら `/sync-to-linux` スキルで linux ブランチに移植する:
1. `/sync-to-linux` を実行
2. 変更の分類（移植可能 / Mac専用 / 要OS判定）を確認
3. A) dotfiles-linux に即時反映 / B) Mac専用として docs/platform-notes.md に記録

コミット・プッシュは必ずユーザー確認後に実行する。

### Linux セットアップ

Linux/WSL 環境でのセットアップは `install/bootstrap-linux.sh` を使用:
```bash
# 前提: chsh -s $(which zsh) でデフォルトシェルを変更済みであること
bash install/bootstrap-linux.sh
```
