# dotfiles

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
git clone git@github.com:YOSHIHIDEShimoji/dotfiles.git ~/dotfiles

# 7. 自動セットアップ実行
cd ~/dotfiles
./install/bootstrap.sh
```

### 既存環境での簡易セットアップ

```bash
# リポジトリをクローン
git clone git@github.com:YOSHIHIDEShimoji/dotfiles.git ~/dotfiles

# セットアップスクリプトを実行
cd ~/dotfiles/install
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

`scripts/john/wordlists/rockyou.txt`（約140MB）をダウンロードします。`.gitignore` 対象のためリポジトリには含まれず、パスワード解析を使用する場合にのみ実行してください。rockyou.txt の詳細は [`scripts/john/README.md`](scripts/john/README.md) を参照してください。

## ディレクトリ構造

```
dotfiles/
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
│   ├── starship/                        # Starshipテーマ集（current.toml を sstyle で切替）
│   ├── functions/                       # カスタム関数
│   └── links.prop                       # シンボリックリンク定義
├── ripgrep/                             # ripgrep共通設定
│   └── config                           # RIPGREP_CONFIG_PATH が読む既定オプション
├── tmux/                                # tmux設定
│   ├── tmux.conf                        # tmux設定ファイル（~/.tmux.confにリンク）
│   ├── README.md                        # キーバインド・操作マニュアル
│   └── links.prop                       # シンボリックリンク定義
├── ssh/                                 # SSH設定
│   ├── config                           # SSH設定ファイル（~/.ssh/configにリンク）
│   └── links.prop                       # シンボリックリンク定義
├── karabiner/                           # Karabiner-Elements設定
│   ├── karabiner.json                   # キーバインド設定
│   └── links.prop                       # シンボリックリンク定義
├── vscode/                              # VS Code設定
│   ├── settings.json                    # エディタ設定
│   ├── extensions.txt                   # 拡張機能リスト（31個）
│   └── links.prop                       # シンボリックリンク定義
├── claude/                              # Claude Code / AI agent設定
│   ├── CLAUDE.md                        # Claude Codeへの指示（~/.claude/CLAUDE.mdにリンク）
│   ├── skills/                          # AI agentスキル群（~/.agents/skillsにリンク）
│   └── links.prop                       # シンボリックリンク定義
├── install/                             # インストール関連
│   ├── bootstrap.sh                     # セットアップスクリプト
│   ├── Brewfile                         # Homebrewパッケージリスト
│   ├── gui-apps.txt                     # GUIアプリ一覧
│   ├── install-mactex-ja.zsh            # MacTeX日本語環境構築
│   ├── setup-john-wordlists.sh          # rockyou.txtワードリスト取得
│   ├── test_bootstrap_dry_run.sh        # bootstrap の副作用なし検証（CIでも実行）
│   ├── welcome.sh                       # セットアップ後の案内表示
│   └── cli-tools/                       # CLIツールインストールスクリプト
│       ├── install-claude-code.sh       # Claude Codeインストール
│       ├── install-gemini-cli.sh        # Gemini CLIインストール
│       └── install-codex.sh             # OpenAI Codexインストール
├── scripts/                             # ユーティリティスクリプト
│   ├── bin/                             # 汎用スクリプト
│   │   ├── transcribe                   # 音声・動画→テキスト文字起こし（whisper.cpp + CoreML）
│   │   ├── excel2csv                    # Excel → CSV 一括変換
│   │   ├── yt2ob                        # YouTube文字起こし→Obsidian frontmatter変換
│   │   ├── launchd_list                 # LaunchAgents の一覧表示
│   │   └── ppdf/                        # PDF操作ツール群（下記参照）
│   ├── lib/                             # スクリプト共通ライブラリ
│   │   ├── launchd_manager.py           # LaunchAgents 操作（launchd_list が利用）
│   │   └── setup_drive.sh               # Google Drive セットアップ（plistから呼ばれる）
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
├── docs/                                # 詳細ドキュメント
│   ├── setup-detail.md                  # bootstrap.sh の詳細
│   └── keybindings.md                   # Ghostty/Karabiner キーバインド
├── .github/workflows/                   # GitHub Actions
│   └── ci.yml                           # push/PR で bootstrap dry-run + 構文チェック
├── LaunchAgents/                        # macOS LaunchAgents
│   └── com.yoshihide.setup_drive.plist  # Google Drive日次セットアップ
└── templates/                           # ファイルテンプレート
    ├── template.docx                    # Word用テンプレート
    ├── template.xlsx                    # Excel用テンプレート
    ├── template.pptx                    # PowerPoint用テンプレート
    └── template-latex/                  # LaTeXサンプルプロジェクト
        └── src/                         # sample.tex, title.tex
```

## bootstrap.sh の仕組み

詳細は [`docs/setup-detail.md`](docs/setup-detail.md) を参照。

## テスト / CI

`install/test_bootstrap_dry_run.sh` が副作用なしで `links.prop` の src 欠落・plist 構文・Brewfile・zsh 関数構文などを検証します（FAIL があれば終了コード 1）。手元で `bootstrap.sh` を走らせる前の事前チェックに使えます。

```bash
bash install/test_bootstrap_dry_run.sh
```

`.github/workflows/ci.yml` が push / PR ごとにこの検証を macOS runner で自動実行します。

## 主な機能

### キーバインド

Ghostty・Karabiner-Elements のキーバインド詳細は [`docs/keybindings.md`](docs/keybindings.md) を参照。

### Zshカスタム関数

| 関数 | 説明 |
|------|------|
| `mkcd` | ディレクトリ作成と同時に移動 |
| `cl` | ディレクトリ移動してls実行 |
| `newtex` | LaTeXプロジェクトをテンプレートから作成 |
| `copyfile` | ファイル内容をクリップボードにコピー |
| `copypath` | ファイルパスをクリップボードにコピー |
| `awake` | システムスリープ防止（macOS専用） |
| `ghopen` | 現在のディレクトリをGitHubで開く |
| `update` | Homebrewパッケージを一括更新（macOS専用） |
| `word` / `excel` / `powerpoint` | Office文書を新規作成して開く |
| `lp` | 低電力モードを切り替える（macOS専用） |
| `o` | ファイル・URLを開く |
| `v` | VS Codeで開く（引数なしでカレントディレクトリ） |
| `sstyle` | Starshipプロンプトのテーマを切り替える |
| `rst` | RStudioプロジェクトを初期化・起動 |
| `zsh_stats` | シェル使用統計 |
| `rr` | Zsh設定の再読み込み |
| `c` | C/C++ファイルをコンパイルして実行 |
| `cm` | Claudeでコミットメッセージを自動生成 |
| `please` | 自然言語の要求からシェルコマンドを生成し、確認してから実行（`claude` CLI） |
| `explain` | コマンドやコードを日本語で簡潔に説明（`claude` CLI） |
| `wtf` | 直前の失敗コマンドの原因と修正案を診断（`claude` CLI。再実行はしない） |
| `ask` | Windows 上のローカル LLM（Ollama）に質問（`--model` で指定、`ssh win` 経由） |
| `extract` | アーカイブを拡張子から判別して展開（tar/zip/7z/rar/gz 等） |
| `take` | ディレクトリを作成して移動（git URLならclone、アーカイブなら展開して移動） |
| `killport` | 指定TCPポートを使用中のプロセスを終了 |
| `fkill` | fzfでプロセスを選択して終了 |
| `fco` | fzfでgitブランチを選択して切り替え |

> `extract` / `take` は未対応ツール（`unar`・`7z` 等）が無くても壊れず、`fkill` / `fco` は `fzf` 不在時に案内を出して終了します。
> `please` / `explain` / `wtf` は `claude` CLI を、`ask` は `ssh win` 経由の Ollama を使い、オフライン・レート制限時は静かに失敗します。`please` は生成コマンドを無確認実行せず、必ず確認プロンプトを挟みます。

### ターミナル統合（補完・fzf・検索）

| 項目 | 内容 |
|------|------|
| 補完 | `zstyle` で矢印キー選択（menu select）・大文字小文字を無視した一致・色付き候補・グループ表示を有効化 |
| fzf | `fd` をバックエンドに（`.gitignore` 尊重・hidden込み）、`Ctrl-T` は `bat`、`Alt-C` は `eza --tree` でプレビュー |
| ripgrep | `ripgrep/config`（`RIPGREP_CONFIG_PATH` 経由）で smart-case・hidden・ノイズ除外を既定化 |
| ページャ | `bat` を `MANPAGER` に設定し man をシンタックスハイライト表示 |
| 履歴 | `atuin`（インストール時）が `Ctrl-R` を SQLite 全文検索に置き換え。上下矢印は既存の前方一致履歴検索を維持 |
| プラグイン | `zsh-you-should-use` を読み込み、定義済みエイリアスをフル入力すると通知 |

いずれも該当ツールが未インストールの環境ではガードにより無効化され、素のシェルとして正常起動します。

## スクリプト群 (scripts/)

### PDFツール (ppdf/)

`qpdf`・`pdfjam`・`pikepdf`・`hashcat` 等を使ったPDF操作ツール群。ターミナルのどこからでもコマンド名だけで呼び出せる。

詳細なオプションや使用例は **[scripts/ppdf/README.md](scripts/ppdf/README.md)** を参照。

| コマンド | 概要 |
|---------|------|
| `ppdf_unlock` | 暗号化解除（パスワード指定対応、クリーニング付き） |
| `ppdf_crack` | パスワード解析（辞書・マスク・総当たり） |
| `ppdf_extract` | 指定ページの抽出（odd/even指定対応） |
| `ppdf_split` | 指定枚数ごとに分割（N-up処理オプション付き） |
| `ppdf_concatenate` | ディレクトリ内PDFを結合（編集制限解除） |
| `ppdf_make_num` | N-upレイアウト適用（複数ページを1枚にまとめる） |

### ブックマークスクリプト (bookmark/)

Chrome を特定のプロファイル・URLで起動するスクリプト群です。

- `open_chrome_personal.sh` - 個人用プロファイルで起動
- `open_chrome_chiba-u.sh` - 大学用プロファイルで起動
- `open_ai_urls.sh` - AI系サービス（ChatGPT, Claude等）を一括起動

### ユーティリティ (bin/)

| コマンド | 概要 |
|---------|------|
| `transcribe` | 音声・動画ファイルを文字起こし（m4a/mp4等対応）。whisper.cpp + CoreML で M4 Neural Engine を活用。1時間の音声を約3分で処理。`--summary` で Windows の Ollama による要約を先頭に追記 |
| `excel2csv` | Excel ファイル（.xlsx）を CSV に一括変換 |
| `yt2ob` | YouTube文字起こしメモを Obsidian frontmatter 形式に変換（出力先は `YT2OB_OUTPUT_DIR` で上書き可） |
| `launchd_list` | `~/dotfiles/LaunchAgents/` 配下のジョブを一覧表示（スケジュール・次回実行時刻・ステータス付き） |

### パスワード解析ツール (john/)

`john`（John the Ripper）と `hashcat` を使ったパスワード解析スクリプト群です。PDF・Office・ZIP・RAR・DMG など各種フォーマットのハッシュ抽出から辞書攻撃・ルールベース攻撃まで対応しています。

詳細なセットアップ手順・使い方・rockyou.txt の説明は [`scripts/john/README.md`](scripts/john/README.md) を参照してください。

## SSH設定 (ssh/)

`ssh/config` を `~/.ssh/config` にシンボリックリンクで管理。`bootstrap.sh` 実行時に `~/.ssh/cm/` (ControlMaster ソケット用) も自動作成されます。

## tmux設定 (tmux/)

`tmux/tmux.conf` を `~/.tmux.conf` にシンボリックリンクで管理。Prefix キーは `Ctrl + s`。

キーバインド・操作マニュアルの詳細は **[tmux/README.md](tmux/README.md)** を参照。

## Claude Code / AI Agent設定 (claude/)

`claude/CLAUDE.md` を `~/.claude/CLAUDE.md` に、`claude/skills/` を `~/.agents/skills` にシンボリックリンクで管理。

- **CLAUDE.md**: Claude Codeへの指示・ルールを記述
- **skills/**: AI agentスキル群。`~/.claude/skills` → `~/.agents/skills` → `claude/skills/` の2段リンクで全agentから参照可能

新しいスキルは `claude/skills/` 配下にインストールする。

## VS Code設定

`vscode/settings.json` をシンボリックリンクで管理し、拡張機能を `extensions.txt` から自動インストールします。

## LaunchAgents

`com.yoshihide.setup_drive.plist` により、Google Driveのシンボリックリンクを日次で自動セットアップします。`bootstrap.sh` 実行時に `~/Library/LaunchAgents/` に自動リンク・ロードされます。


## カスタマイズ

### 新しい関数の追加
```bash
# zsh/functions/に新しいファイルを作成
echo 'echo "Hello, $1!"' > ~/dotfiles/zsh/functions/hello

# zshrcを再読み込み
rr
```

### Brewfileの編集

```bash
# 現在の Homebrew パッケージと VS Code 拡張機能をダンプしてコミット
dump
```

`dump` コマンドは `install/Brewfile` と `vscode/extensions.txt` を現在の環境から自動更新し、コミットまで行います。

---

## 作者

**Yoshihide Shimoji**
- GitHub: [@YOSHIHIDEShimoji](https://github.com/YOSHIHIDEShimoji)
- Email: g.y.shimoji@gmail.com
