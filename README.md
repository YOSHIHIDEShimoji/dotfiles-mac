# dotfiles-mac: README

## 🔧 プロジェクトの目的

macOS 上で Linux 同様に `~/.zshrc` や `~/.gitconfig` をクリーンに保ちながら、dotfiles リポジトリによって環境構築を自動化する。

---

## 📁 ディレクトリ構成

```
dotfiles-mac/
├── README.md # このファイル
│
├── git/
│ ├── gitconfig # Git の設定（modular include 対応）
│ ├── gitignore_global # グローバル Git ignore
│ └── links.prop # ~/.gitconfig  ~/.gitignore_globalへのリンク定義
│
├── install/
│ ├── bootstrap.sh # dotfiles セットアップスクリプト
│ └── Brewfile # CLI / GUI アプリ一括管理ファイル
│
├── karabiner/
│ ├── karabiner.json # キーリマップ設定
│ └── links.prop # ~/.config/karabiner へのリンク定義
│
├── scripts/
│
└── zsh/
    ├── .zshrc # zsh 設定ファイル（modular 読み込み）
    ├── aliases.sh # エイリアス設定
    ├── exports.sh # PATH 等の export 設定
    ├── functions.sh # 自作関数（web_search, copypath 等）
    ├── links.prop # ~/.zshrc へのリンク定義
    ├── plugins/ # zsh プラグイン群（submodule）
    │   ├── zsh-autosuggestions
    │   ├── zsh-completions
    │   └── zsh-syntax-highlighting
    │
    └── themes/ # プロンプトテーマ（powerlevel10k 対応）
```

---

## 🛠 セットアップ手順

以下の手順で環境構築を行います。

```zsh
# 1. Xcode Command Line Tools のインストール（手動）
xcode-select --install

# 2. Homebrew のインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. git / PATH 設定
brew install git
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# 4. SSH 鍵生成と GitHub 設定
ssh-keygen -t ed25519 -C "g.y.shimoji@gmail.com"
cat ~/.ssh/id_ed25519.pub

# 5. GitHub の SSH Key に上記公開鍵を貼り付け
ssh -T git@github.com 

# 6. dotfiles リポジトリをクローン（サブモジュール付き）
git clone --recursive git@github.com:YOSHIHIDEShimoji/dotfiles-mac.git ~/dotfiles-mac
cd ~/dotfiles-mac

# 7. bootstrap スクリプトを実行（自動リンク & インストール）
./install/bootstrap.sh
```

このスクリプトにより以下が実行される：

* `zsh/links.prop` や `git/links.prop` に基づいて dotfiles を `~` 以下にシンボリックリンク
* Brewfile に基づいて CLI / GUI アプリをインストール
* zsh プラグイン用のサブモジュールも自動的にセットアップ

---

## 💻 Brewfile でインストールされる主要アプリ

### CLI

```brewfile
brew "git"
brew "gh"
brew "fzf"
brew "ripgrep"
brew "bat"
brew "wget"
brew "curl"
brew "jq"
brew "tree"
brew "python"
```

### GUI

```brewfile
cask "google-chrome"
cask "spotify"
cask "discord"
cask "visual-studio-code"
cask "coteditor"
cask "clipy"
cask "rectangle"
cask "hiddenbar"
cask "alfred"
cask "hammerspoon"
cask "istat-menus"
cask "slack"
cask "karabiner-elements"
cask "iterm2"
```

※ GUI アプリをすでに手動でインストール済みでも、上書きされることはありません（ただしバージョン差異による警告は出る可能性あり）。

---

## 🧩 手動でインストールが必要なアプリ一覧

以下のアプリは Brew または MAS で提供されていない、あるいは GUI 経由でのインストールが推奨されるため、手動でインストールしてください：

* Google 日本語入力
* Google Drive
* Adobe Acrobat Reader
* Adobe Creative Cloud
* CleanMyMac
* AppCleaner
* BetterTouchTool
* KeyboardCleanTool
* Whisper Transcription
* MonitorControl Lite
* MiniCalendar
* Microsoft Word / Excel / PowerPoint

---

## 🔗 リンク内容（例）

```sh
~/.zshrc                           → dotfiles-mac/zsh/.zshrc
~/.gitconfig                       → dotfiles-mac/git/.gitconfig
~/.gitignore_global                → dotfiles-mac/git/.gitignore_global
~/.config/karabiner/karabiner.json → dotfiles-mac/git/.gitignore_global
```

---

## 🧠 補足

* zsh のカスタム関数は `functions.sh` に集約（`copypath`, `copyfile`, `web_search`, `zsh_stats` など）
* サブモジュールは `.gitmodules` に記録され、clone 時に `--recursive` を付けることで取得
* `web_search` は `ohmyzsh-web-search` から必要部分を抜粋して使用
* 補完・シンタックスハイライトは `zsh-users/zsh-completions`, `zsh-users/zsh-autosuggestions`, `zsh-users/zsh-syntax-highlighting` による
