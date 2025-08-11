# dotfiles-mac

macOS環境用のdotfiles管理リポジトリです。Zsh、Git、Karabiner-Elements、Homebrewの設定を一元管理し、新しいMac環境を素早くセットアップできます。

## ✨ 特徴

- 🚀 **ワンコマンドセットアップ** - `bootstrap.sh`で全ての設定を自動適用
- ⌨️ **高度なキーバインド** - Karabiner-ElementsでCtrlキーをナビゲーションモードに変換
- 📦 **パッケージ管理** - Brewfileで必要なアプリケーションを一括インストール
- 🛠 **便利な関数群** - 日常作業を効率化する20以上のカスタム関数
- 🎨 **Zshカスタマイズ** - プラグイン、エイリアス、補完機能を完備

## 📋 必要要件

- macOS (最新版推奨)
- Xcode Command Line Tools
- [Homebrew](https://brew.sh/ja/)
- Git
- GitHub アカウント（SSH設定済み）

## 🚀 クイックスタート

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

# 6. dotfilesリポジトリをクローン（サブモジュール付き）
git clone --recursive git@github.com:YOSHIHIDEShimoji/dotfiles-mac.git ~/dotfiles-mac

# 7. 自動セットアップ実行
cd ~/dotfiles-mac
./install/bootstrap.sh
```

### 既存環境での簡易セットアップ

```bash
# リポジトリをクローン
git clone --recursive git@github.com:YOSHIHIDEShimoji/dotfiles-mac.git ~/dotfiles-mac

# セットアップスクリプトを実行
cd ~/dotfiles-mac/install
./bootstrap.sh
```

## 📁 ディレクトリ構造

```
dotfiles-mac/
├── git/                  # Git設定
│   ├── gitconfig        # Git全般設定
│   └── gitignore_global # グローバル.gitignore
├── zsh/                  # Zsh設定
│   ├── zshrc            # メインのZsh設定
│   ├── aliases.sh       # エイリアス定義
│   ├── exports.sh       # 環境変数
│   ├── functions/       # カスタム関数
│   ├── plugins/         # Zshプラグイン
│   └── themes/          # Zshテーマ
├── karabiner/           # Karabiner-Elements設定
│   └── karabiner.json   # キーバインド設定
├── install/             # インストール関連
│   ├── bootstrap.sh     # セットアップスクリプト
│   └── Brewfile         # Homebrewパッケージリスト
├── scripts/             # ユーティリティスクリプト
│   ├── open_chrome_personal.sh  # 個人用Chrome起動
│   └── open_chrome_chiba-u.sh   # 仕事用Chrome起動
└── templates/           # ファイルテンプレート
    ├── empty.docx       # Word用テンプレート
    ├── empty.xlsx       # Excel用テンプレート
    └── empty.pptx       # PowerPoint用テンプレート
```

## ⚙️ 主な機能

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
- `mkcd`: ディレクトリ作成と同時に移動
- `cl`: ディレクトリ移動してls実行
- `gbd`: 現在のGitブランチを安全に削除
- `ghopen`: 現在のディレクトリをGitHubで開く
- `update`: Homebrewパッケージを一括更新
- `word/excel/powerpoint`: Office文書を新規作成して開く
- `web_search`: ターミナルから各種検索エンジンで検索

### Gitエイリアス
- `git st`: status
- `git co`: checkout
- `git br`: branch
- `git cm`: commit -m
- `git lg`: グラフ形式のログ表示

## 📦 インストールされるアプリケーション

### CLI ツール
- git, gh, fzf, ripgrep, bat, wget, curl, jq, tree, python
- zoxide（スマートなディレクトリ移動）※手動インストール推奨

### GUI アプリケーション
- Google Chrome, Visual Studio Code
- Discord, Spotify, Slack
- iTerm2, Alfred, Rectangle
- Karabiner-Elements
- その他開発・生産性向上ツール

## 🔧 カスタマイズ

### 新しい関数の追加
```bash
# zsh/functions/に新しいファイルを作成
echo 'echo "Hello, $1!"' > ~/dotfiles-mac/zsh/functions/hello

# zshrcを再読み込み
rr
```

### Brewfileの編集
```bash
# 新しいアプリケーションを追加
echo 'cask "notion"' >> ~/dotfiles-mac/install/Brewfile

# インストール実行
brew bundle --file=~/dotfiles-mac/install/Brewfile
```

## 🆘 トラブルシューティング

### シンボリックリンクが作成されない
```bash
# 手動でリンクを作成
ln -sf ~/dotfiles-mac/zsh/zshrc ~/.zshrc
ln -sf ~/dotfiles-mac/git/gitconfig ~/.gitconfig
```

### Karabiner-Elementsが動作しない
1. システム環境設定 → セキュリティとプライバシー → プライバシー
2. アクセシビリティでKarabiner-Elementsを許可

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 👤 作者

**Yoshihide Shimoji**
- GitHub: [@YOSHIHIDEShimoji](https://github.com/YOSHIHIDEShimoji)
- Email: g.y.shimoji@gmail.com

## 🤝 貢献

Issue報告やPull Requestは歓迎です！

---

⭐ このリポジトリが役立ったら、スターをお願いします！