# dotfiles-mac

macOS環境用のdotfiles管理リポジトリです。Zsh、Git、Karabiner-Elements、VS Code、Homebrewの設定を一元管理し、新しいMac環境を素早くセットアップできます。

## 特徴

- **ワンコマンドセットアップ** - `bootstrap.sh`で全ての設定を自動適用
- **高度なキーバインド** - Karabiner-ElementsでCtrlキーをナビゲーションモードに変換
- **パッケージ管理** - Brewfileで必要なアプリケーションを一括インストール
- **便利な関数群** - 日常作業を効率化する20以上のカスタム関数
- **Zshカスタマイズ** - プラグイン、エイリアス、補完機能を完備
- **VS Code設定同期** - settings.jsonと拡張機能を自動管理
- **LaunchAgents** - 日次タスクの自動実行

## 必要要件

- macOS (最新版推奨)
- Xcode Command Line Tools
- [Homebrew](https://brew.sh/ja/)
- Git
- GitHub アカウント（SSH設定済み）

## クイックスタート

### 新しいMacでの完全セットアップ

```bash
# 1. Xcode Command Line Tools のインストール
xcode-select --install

# 2. Homebrew のインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Git インストールとPATH設定
brew install git
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# 4. SSH鍵生成とGitHub設定
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub
# → GitHubの Settings > SSH Keys に公開鍵を登録

# 5. 接続確認
ssh -T git@github.com

# 6. dotfilesリポジトリをクローン
git clone git@github.com:YOSHIHIDEShimoji/dotfiles-mac.git ~/dotfiles-mac

# 7. 自動セットアップ実行
cd ~/dotfiles-mac
./install/bootstrap.sh
```

### 既存環境での簡易セットアップ

```bash
# リポジトリをクローン
git clone git@github.com:YOSHIHIDEShimoji/dotfiles-mac.git ~/dotfiles-mac

# セットアップスクリプトを実行
cd ~/dotfiles-mac/install
./bootstrap.sh
```

## オプションのインストール

`bootstrap.sh` に含まれない追加環境は必要に応じて個別に実行します。

### MacTeX 日本語環境

```bash
zsh install/install-mactex-ja.zsh
```

MacTeX と日本語フォント環境を構築します。

### CLIツール

```bash
bash install/cli-tools/install-claude-code.sh   # Claude Code
bash install/cli-tools/install-gemini-cli.sh    # Gemini CLI
bash install/cli-tools/install-codex.sh         # OpenAI Codex
```

### John/Hashcat ワードリスト

```bash
bash install/setup-john-wordlists.sh
```

`scripts/john/wordlists/rockyou.txt`（約140MB）をダウンロードします。rockyou.txtは2009年のRockYou.comデータ漏洩で流出した実際のパスワード約1,400万件のリストで、パスワード解析ツールの定番ワードリストです。`.gitignore` 対象のためリポジトリには含まれません。

## ディレクトリ構造

```
dotfiles-mac/
├── git/                                 # Git設定
│   ├── gitconfig                        # Git全般設定
│   ├── gitignore_global                 # グローバル.gitignore
│   └── links.prop                       # シンボリックリンク定義
├── ghostty/                             # Ghostty設定
│   ├── config                           # Ghostty設定ファイル
│   └── links.prop                       # シンボリックリンク定義
├── zsh/                                 # Zsh設定
│   ├── zshrc                            # メインのZsh設定
│   ├── zshenv                           # 環境変数（ログイン前に読み込み）
│   ├── aliases.sh                       # エイリアス定義
│   ├── exports.sh                       # 環境変数
│   ├── starship.toml                    # Starshipプロンプト設定
│   ├── functions/                       # カスタム関数（22個）
│   └── links.prop                       # シンボリックリンク定義
├── karabiner/                           # Karabiner-Elements設定
│   ├── karabiner.json                   # キーバインド設定
│   └── links.prop                       # シンボリックリンク定義
├── vscode/                              # VS Code設定
│   ├── settings.json                    # エディタ設定
│   ├── extensions.txt                   # 拡張機能リスト（26個）
│   └── links.prop                       # シンボリックリンク定義
├── install/                             # インストール関連
│   ├── bootstrap.sh                     # セットアップスクリプト
│   ├── Brewfile                         # Homebrewパッケージリスト
│   ├── gui-apps.txt                     # GUIアプリ一覧
│   ├── install-mactex-ja.zsh            # MacTeX日本語環境構築
│   ├── setup-john-wordlists.sh          # rockyou.txtワードリスト取得
│   └── cli-tools/                       # CLIツールインストールスクリプト
│       ├── install-claude-code.sh       # Claude Codeインストール
│       ├── install-gemini-cli.sh        # Gemini CLIインストール
│       └── install-codex.sh             # OpenAI Codexインストール
├── scripts/                             # ユーティリティスクリプト
│   ├── bin/                             # 汎用スクリプト
│   │   ├── setup_drive.sh               # Google Driveシンボリックリンク設定
│   │   ├── dump.sh                      # 設定ダンプ
│   │   ├── launchd_manager.py           # launchd管理ツール
│   │   └── word2ref                     # Word文書から参考文献抽出
│   ├── bookmark/                        # Chrome起動スクリプト
│   │   ├── open_chrome_personal.sh      # 個人用Chrome起動
│   │   ├── open_chrome_chiba-u.sh       # 大学用Chrome起動
│   │   └── open_ai_urls.sh              # AI系サービス一括起動
│   ├── ppdf/                            # PDF操作ツール群
│   │   ├── ppdf_unlock                  # PDFパスワード解除
│   │   ├── ppdf_crack                   # PDFパスワード解析
│   │   ├── ppdf_extract                 # PDFページ抽出
│   │   ├── ppdf_split                   # PDF分割
│   │   ├── ppdf_concatenate             # PDF結合
│   │   └── ppdf_make_num                # PDFページ番号付与
│   └── john/                            # パスワード解析ツール群
│       ├── src/                         # ハッシュ抽出スクリプト
│       └── wordlists/                   # ワードリスト（rockyou.txtは.gitignore対象）
├── LaunchAgents/                        # macOS LaunchAgents
│   └── com.yoshihide.setup_drive.plist  # Google Drive日次セットアップ
└── templates/                           # ファイルテンプレート
    ├── empty.docx                       # Word用テンプレート
    ├── empty.xlsx                       # Excel用テンプレート
    ├── empty.pptx                       # PowerPoint用テンプレート
    └── latex-sample/                    # LaTeXサンプルプロジェクト
        └── src/                         # sample.tex, title.tex
```

## bootstrap.sh の仕組み

`install/bootstrap.sh` は以下の処理を順に実行します:

1. **LaunchAgentsの設定** - `LaunchAgents/` 内の `.plist` を `~/Library/LaunchAgents/` にシンボリックリンクし、未ロードならロード
2. **sudoers設定** - `pmset` をパスワードなしで実行するための sudoers ルールを追加
3. **シンボリックリンク作成** - 各ディレクトリの `links.prop` に従い設定ファイルをリンク
   - `zsh/links.prop`: `zshrc`, `zshenv` → `~/`、`starship.toml` → `~/.config/`
   - `git/links.prop`: `gitconfig`, `gitignore_global` → `~/`
   - `karabiner/links.prop`: `karabiner.json` → `~/.config/karabiner/`
   - `vscode/links.prop`: `settings.json` → VS Codeユーザー設定
   - `ghostty/links.prop`: `config` → `~/Library/Application Support/com.mitchellh.ghostty/`
4. **VS Code拡張機能のインストール** - `vscode/extensions.txt` の拡張機能を自動インストール
5. **Homebrewパッケージのインストール** - `install/Brewfile` に従いパッケージを一括インストール

## 主な機能

### Ghostty設定

- **フォント・外観**: フォントサイズ12、Bluloco Darkテーマ、バースタイルカーソル
- **ペインナビゲーション**: `Ctrl+Option+i/j/k/l`（上/左/下/右）
- **ペイン分割**: `Ctrl+Shift+v`（右に分割）、`Ctrl+Shift+h`（下に分割）
- **ペインを閉じる**: `Ctrl+x`

### Karabiner-Elements設定
- **Caps Lock → Control**: Caps LockキーをControlキーに変換
- **Controlナビゲーションモード**: 左Controlキー押下中に以下のキーバインドが有効
  - `i/j/k/l`: 矢印キー (上/左/下/右)
  - `u/o`: 行頭/行末へ移動
  - `h`: Enter
  - `n/m`: Backspace/Delete
  - `y`: Escape
  - その他のアルファベット: 大文字に変換

### Zshカスタム関数

| 関数 | 説明 |
|------|------|
| `mkcd` | ディレクトリ作成と同時に移動 |
| `cl` | ディレクトリ移動してls実行 |
| `newtex` | LaTeXプロジェクトをテンプレートから作成 |
| `activate` | Python venv有効化 |
| `copyfile` | ファイル内容をクリップボードにコピー |
| `copypath` | ファイルパスをクリップボードにコピー |
| `awake` | システムスリープ防止 |
| `gbd` | 現在のGitブランチを安全に削除 |
| `ghopen` | 現在のディレクトリをGitHubで開く |
| `update` | Homebrewパッケージを一括更新 |
| `word` / `excel` / `powerpoint` | Office文書を新規作成して開く |
| `lp` | 低電力モードを切り替える |
| `zsh_stats` | シェル使用統計 |
| `rr` | Zsh設定の再読み込み |
| `c` | ディレクトリ移動ユーティリティ |

### Gitエイリアス

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

### Zshエイリアス

**ターミナル操作:**
`..`, `...`(ディレクトリ移動), `o`(Finderで開く), `v`(VS Codeで開く), `h`(履歴), `ll`, `la`

**Git短縮:**
`g`, `gs`, `gco`, `gbr`, `gcm`, `gca`, `glast`, `glg`, `gdf`, `gdfc`, `gunstage`, `gundo`, `gpu`, `gpl`

**Web検索 (`web_search` ベース):**
`google`, `youtube`, `scholar`, `chatgpt`, `claudeai`, `grok`, `deepl`, `github`, `stackoverflow`, `reddit`, `ddg`, `wiki`, `news`, `image` など30以上

**ネットワーク:**
`myip`(グローバルIP表示), `port`(ポート確認)

## スクリプト群 (scripts/)

### PDFツール (ppdf/)

PDF操作のためのコマンドラインツール群です。`qpdf`, `mupdf-tools`, `poppler`, `john`, `hashcat` 等に依存します。

| コマンド | 説明 |
|---------|------|
| `ppdf_unlock` | パスワード付きPDFのロック解除 |
| `ppdf_crack` | PDFパスワードの解析 |
| `ppdf_extract` | PDFから指定ページを抽出 |
| `ppdf_split` | PDFを複数ファイルに分割 |
| `ppdf_concatenate` | 複数PDFを結合 |
| `ppdf_make_num` | PDFにページ番号を付与 |

### ブックマークスクリプト (bookmark/)

Chrome を特定のプロファイル・URLで起動するスクリプト群です。

- `open_chrome_personal.sh` - 個人用プロファイルで起動
- `open_chrome_chiba-u.sh` - 大学用プロファイルで起動
- `open_ai_urls.sh` - AI系サービス（ChatGPT, Claude等）を一括起動

### ユーティリティ (bin/)

- `setup_drive.sh` - Google Driveのシンボリックリンクを設定
- `dump.sh` - 現在の環境設定をダンプ
- `launchd_manager.py` - launchd plistの管理ツール
- `word2ref` - Word文書から参考文献を抽出

### パスワード解析ツール (john/)

`john`（John the Ripper）と `hashcat` を使ったパスワード解析ウィザードです。PDFのハッシュ抽出からHashcatによるクラックまでをウィザード形式でサポートします。M4チップに最適化されています。

**環境情報:**
- Python venv: `scripts/.venv`
- Hashcat Rules: `/opt/homebrew/opt/hashcat/share/doc/hashcat/rules/`
- Wordlist: `scripts/john/wordlists/rockyou.txt`

**セットアップ:**
```bash
# Python venvのセットアップ
python3 -m venv scripts/.venv
source scripts/.venv/bin/activate
pip install inquirer

# ワードリストの取得（約140MB、.gitignore対象）
bash install/setup-john-wordlists.sh
```

## VS Code設定

`vscode/settings.json` をシンボリックリンクで管理し、26個の拡張機能を `extensions.txt` から自動インストールします。

主な拡張機能:
- GitHub Copilot / Copilot Chat
- LaTeX Workshop
- Python (Pylance, debugpy)
- C/C++ Extension Pack
- Java Extension Pack (Gradle, Maven, Debug, Test)
- Markdown All in One / Markdown PDF
- Rainbow CSV
- Live Server
- Code Spell Checker

## LaunchAgents

`com.yoshihide.setup_drive.plist` により、Google Driveのシンボリックリンクを日次で自動セットアップします。`bootstrap.sh` 実行時に `~/Library/LaunchAgents/` に自動リンク・ロードされます。

## インストールされるアプリケーション

### CLI ツール (24個)

bat, curl, ffmpeg, fzf, gh, git, git-filter-repo, hashcat, imagemagick, john, jq, mupdf-tools, node, openjdk@17, pandoc, poppler, pyenv, pyenv-virtualenv, qpdf, ripgrep, tree, wget, zoxide, zsh-you-should-use

### GUI アプリケーション (30個)

Adobe Acrobat Reader, Adobe Creative Cloud, Alfred, AppCleaner, BetterTouchTool, Clipy, CotEditor, Discord, Ghostty, Google Chrome, Google Drive, Google Japanese IME, Hammerspoon, Hidden Bar, iStat Menus, iTerm2, Karabiner-Elements, KeyboardCleanTool, Maccy, MacTeX, Microsoft Office, Microsoft Teams, MonitorControl, Rectangle, Slack, Spotify, Visual Studio Code, Font IPA Ex, Font IPA, Font Meslo LG Nerd Font

## カスタマイズ

### 新しい関数の追加
```bash
# zsh/functions/に新しいファイルを作成
echo 'echo "Hello, $1!"' > ~/dotfiles-mac/zsh/functions/hello

# zshrcを再読み込み
rr
```

### Brewfileの編集

```bash
# 現在の Homebrew パッケージと VS Code 拡張機能をダンプしてコミット
dump
```

`dump` コマンドは `install/Brewfile` と `vscode/extensions.txt` を現在の環境から自動更新し、コミットまで行います。

## 作者

**Yoshihide Shimoji**
- GitHub: [@YOSHIHIDEShimoji](https://github.com/YOSHIHIDEShimoji)
- Email: g.y.shimoji@gmail.com
