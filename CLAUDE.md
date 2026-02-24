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
