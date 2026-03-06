# dotfiles-linux

Linux / WSL 環境用の dotfiles リポジトリです。Zsh、Git、VS Code の設定を一元管理し、新しい Linux 環境を素早くセットアップできます。
[macOS 版](https://github.com/YOSHIHIDEShimoji/dotfiles-mac/tree/main) をベースに Linux / WSL 向けに適合させたブランチです。

## 特徴

- **ワンコマンドセットアップ** — `bootstrap-linux.sh` で zsh・パッケージ・設定を自動適用
- **WSL 対応** — クリップボード等の差異をファイル内 OS 判定で吸収
- **Zsh カスタマイズ** — プラグイン、エイリアス、補完機能を完備
- **VS Code 設定同期** — settings.json と拡張機能を自動管理

## 必要要件

- Ubuntu 22.04 以上（または互換 Debian 系）または WSL2 (Ubuntu)
- Git
- sudo 権限
- インターネット接続

## クイックスタート

### 重要: セットアップ前にデフォルトシェルを zsh に変更する

本 dotfiles は **zsh** を前提としています。Ubuntu はデフォルトが bash のため、**リポジトリのクローン前に必ず**以下の手順でシェルを変更してください。

```bash
# 1. zsh をインストール
sudo apt update && sudo apt install -y zsh

# 2. デフォルトシェルを zsh に変更
chsh -s $(which zsh)

# 3. ログアウト → 再ログイン（変更を反映）
# WSL の場合: ターミナルを閉じて再度 wsl ~ で入り直す
```

### セットアップ手順

```bash
# 1. GitHub の SSH 鍵を設定（未設定の場合）
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub
# → GitHub の Settings > SSH Keys に公開鍵を登録

# 2. 接続確認
ssh -T git@github.com

# 3. dotfiles リポジトリを linux ブランチとしてクローン
git clone -b linux git@github.com:YOSHIHIDEShimoji/dotfiles-mac.git ~/dotfiles-linux

# 4. セットアップスクリプトを実行
cd ~/dotfiles-linux
bash install/bootstrap-linux.sh

# 5. ログアウト → 再ログインして zsh が適用されたことを確認
```

## ディレクトリ構造

```
dotfiles-linux/
├── git/                      # Git 設定
│   ├── gitconfig             # Git 全般設定
│   ├── gitignore_global      # グローバル .gitignore
│   └── links.prop            # シンボリックリンク定義
├── zsh/                      # Zsh 設定
│   ├── zshrc                 # メインの Zsh 設定（OS 判定あり）
│   ├── zshenv                # 環境変数（pyenv PATH 等）
│   ├── aliases.sh            # エイリアス定義（OS 判定あり）
│   ├── exports.sh            # PATH・環境変数（OS 判定あり）
│   ├── starship.toml         # Starship プロンプト設定
│   ├── functions/            # カスタム関数
│   └── links.prop            # シンボリックリンク定義
├── vscode/                   # VS Code 設定
│   ├── settings.json         # エディタ設定
│   ├── extensions.txt        # 拡張機能リスト
│   └── links.prop            # シンボリックリンク定義
├── install/                  # インストール関連
│   ├── bootstrap-linux.sh    # Linux/WSL セットアップスクリプト
│   ├── Aptfile               # apt パッケージリスト（macOS の Brewfile に相当）
│   └── cli-tools/            # CLI ツールインストールスクリプト
│       ├── install-claude-code.sh
│       ├── install-gemini-cli.sh
│       └── install-codex.sh
├── scripts/                  # ユーティリティスクリプト
│   ├── bin/                  # 汎用スクリプト
│   ├── ppdf/                 # PDF 操作ツール群
│   └── john/                 # パスワード解析ツール群
├── platform-notes.md         # Mac専用/Linux専用の移植ルール定義
└── templates/                # ファイルテンプレート
    └── latex-sample/         # LaTeX サンプルプロジェクト
```

## bootstrap-linux.sh の仕組み

`install/bootstrap-linux.sh` は以下の処理を順に実行します:

1. **`Aptfile` 読み込み** — `[common]` + `[linux]` or `[wsl]` のパッケージリストを構築
2. **特殊リポジトリのセットアップ** — eza / ghostty / VS Code / Chrome など公式 apt 未収録のものはリポジトリを自動追加
3. **zsh 確認** — 未インストールの場合 `apt` で先行インストール
4. **デフォルトシェルの変更** — `chsh -s $(which zsh)`
5. **パッケージ一括インストール** — `apt-get install -y` で Aptfile のパッケージを全件インストール
6. **シンボリックリンク補完** — `fd`（fd-find）、`bat`（batcat）のエイリアスリンク作成
7. **npm パッケージ** — `tldr`
8. **dotfiles シンボリックリンク作成** — `zsh/links.prop`, `git/links.prop`（純 Linux は `ghostty/links.prop` も）
9. **starship / zoxide / pyenv** — 各 curl スクリプトでインストール
10. **VS Code 拡張機能** — 純 Linux: `vscode/extensions.txt` から一括インストール / WSL: スキップ

## OS 判定の仕組み

`zshrc`, `exports.sh`, `aliases.sh` はファイル内に OS 判定を持ちます:

```zsh
if [[ "$(uname)" == "Darwin" ]]; then
  # Mac 固有の設定（Linux 環境では自動スキップ）
elif [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  # WSL 固有の設定
else
  # 純 Linux 設定
fi
```

## WSL 固有の設定

Linux / WSL の差異は `aliases.sh` 内で自動吸収されます:

| 機能 | WSL | 純 Linux |
|------|-----|----------|
| クリップボードコピー | `/mnt/c/Windows/System32/clip.exe` | `xclip -selection clipboard` |
| クリップボードペースト | `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command "Get-Clipboard"` | `xclip -selection clipboard -o` |
| ファイルを開く | `explorer.exe` | `xdg-open` |

## カスタム関数

Linux 環境で利用可能な主な関数:

| 関数 | 説明 |
|------|------|
| `mkcd` | ディレクトリ作成と同時に移動 |
| `cl` | ディレクトリ移動して ls 実行 |
| `copyfile` | ファイル内容をクリップボードにコピー（OS 判定あり） |
| `copypath` | ファイルパスをクリップボードにコピー（OS 判定あり） |
| `ghopen` | 現在のディレクトリを GitHub で開く（OS 判定あり） |
| `rr` | Zsh 設定の再読み込み |
| `c` | C ファイルをコンパイルして実行（OS 判定あり） |
| `zsh_stats` | シェル使用統計 |
| `o` | ファイル・URLを開く（WSL: explorer.exe/ブラウザ、Linux: xdg-open） |
| `update` | apt パッケージを一括更新（Linux 専用） |
| `cm` | Claude でコミットメッセージを自動生成 |
| `newtex` | LaTeX プロジェクトをテンプレートから作成 |

> **注意**: `awake`, `lp` は macOS 専用のため Linux では使用不可。`word` / `excel` / `powerpoint` は WSL 専用（純 Linux では使用不可）。

## Zsh エイリアス

**ターミナル操作:**
`..`, `...`（ディレクトリ移動）, `v`（VS Code で開く）, `h`（履歴）, `l`, `ll`, `la`

**Git 短縮:**
`g`, `gs`, `gco`, `gbr`, `gcm`, `gca`, `glast`, `glg`, `gdf`, `gdfc`, `gunstage`, `gundo`, `gpu`, `gpl`

**Linux/WSL 専用:**
`o`（ファイル・URL を開く）, `copy` / `paste`（クリップボード — WSL: clip.exe / powershell.exe、純 Linux: xclip）

**ネットワーク:**
`myip`（グローバル IP 表示）, `port`（ポート確認）

## Gitエイリアス（gitconfig）

| エイリアス | コマンド |
|-----------|---------|
| `git st` | `status` |
| `git co` | `checkout` |
| `git br` | `branch` |
| `git cm` | `commit -m` |
| `git ca` | `commit -a -m` |
| `git last` | `log -1 HEAD` |
| `git lg` | `log --oneline --graph --all --decorate` |
| `git df` | `diff` |
| `git dfc` | `diff --cached` |
| `git unstage` | `reset HEAD --` |
| `git undo` | `reset --soft HEAD~1` |
| `git pu` | `push` |
| `git pl` | `pull` |

## スクリプト群 (scripts/)

### PDF ツール (ppdf/)

`qpdf`, `mupdf-tools`, `poppler`, `john`, `hashcat` 等に依存します（`apt` でインストール可能）。

| コマンド | 説明 |
|---------|------|
| `ppdf_unlock` | パスワード付き PDF のロック解除 |
| `ppdf_crack` | PDF パスワードの解析 |
| `ppdf_extract` | PDF から指定ページを抽出 |
| `ppdf_split` | PDF を複数ファイルに分割 |
| `ppdf_concatenate` | 複数 PDF を結合 |
| `ppdf_make_num` | PDF にページ番号を付与 |

### パスワード解析ツール (john/)

`john`（John the Ripper）と `hashcat` を使ったパスワード解析ウィザードです。

**セットアップ:**
```bash
# Python venv のセットアップ
python3 -m venv scripts/.venv
source scripts/.venv/bin/activate
pip install inquirer

# ワードリストの取得（約140MB、.gitignore対象）
bash install/setup-john-wordlists.sh
```

## Aptfile のカスタマイズ

`install/Aptfile` が apt でインストールするパッケージを管理します（macOS の `Brewfile` に相当）。

```
[wsl]      — WSL・純 Linux 共通（CLI ツール等）
[linux]    — 純 Linux のみ（[wsl] に加えてインストール）: GUI アプリ等
```

- **WSL**: `[wsl]` のみインストール
- **純 Linux**: `[wsl]` + `[linux]` の両方をインストール

### パッケージを追加する

```bash
# 例: pure Linux に vlc を追加したい場合 → [linux] セクションに追記
# 例: WSL・純 Linux 両方に入れたい CLI ツール → [wsl] セクションに追記
# install/Aptfile を編集:
vlc   # [linux] セクションに追加

# 再実行（冪等性あり、インストール済みはスキップ）
bash install/bootstrap-linux.sh
```

### 特殊リポジトリが必要なパッケージを追加する

以下のパッケージは `bootstrap-linux.sh` がリポジトリを自動追加します:

| パッケージ | リポジトリ |
|-----------|-----------|
| `eza` | deb.gierens.de |
| `ghostty` | apt.ghostty.org |
| `code` | packages.microsoft.com |
| `google-chrome-stable` | dl.google.com |

それ以外の特殊リポジトリが必要なパッケージは `bootstrap-linux.sh` の `case "$pkg"` に追記してください。

## VS Code 設定

`vscode/settings.json` をシンボリックリンクで管理します。`bootstrap-linux.sh` 実行時に自動インストールされます。

> Linux での VS Code 設定パスは `~/.config/Code/User/settings.json`（macOS とは異なる）。`vscode/links.prop` の linux ブランチでは Linux 用パスを使用します。

## オプションのインストール

```bash
# Claude Code
bash install/cli-tools/install-claude-code.sh

# Gemini CLI
bash install/cli-tools/install-gemini-cli.sh

# John/Hashcat ワードリスト（約140MB）
bash install/setup-john-wordlists.sh
```

## macOS との同期

macOS 側（`~/dotfiles-mac`, main ブランチ）で機能追加した場合は、`/sync-to-linux` スキルで Linux ブランチに移植できます。
詳細は macOS 側の [CLAUDE.md](CLAUDE.md) を参照してください。

## 作者

**Yoshihide Shimoji**
- GitHub: [@YOSHIHIDEShimoji](https://github.com/YOSHIHIDEShimoji)
- Email: g.y.shimoji@gmail.com
