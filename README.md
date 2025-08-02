# dotfiles-mac: README

## 🔧 プロジェクトの目的

macOS 上で Linux 同様に `~/.zshrc` や `~/.gitconfig` をクリーンに保ちながら、dotfiles リポジトリによって環境構築を自動化する。

---

## 📁 ディレクトリ構成

```
dotfiles-mac/
├── install/
│   ├── bootstrap.sh        # dotfiles をリンクし、brew bundle を実行
│   └── Brewfile            # CLI / GUI アプリを一括インストール
│
├── zsh/
│   ├── .zshrc              # modular に aliases, exports, functions を読み込む
│   ├── aliases.sh          # エイリアス設定
│   ├── exports.sh          # PATH 等の export 設定
│   ├── functions.sh        # c, gbd, ghopen など自作関数
│   └── links.prop          # ~/.zshrc のリンク定義
│
├── git/
│   ├── .gitconfig          # git 設定をすべて集約
│   ├── .gitignore_global   # グローバル gitignore
│   └── links.prop          # .gitconfig / .gitignore_global のリンク定義
│
└── README.md
```

---

## 🛠 セットアップ手順

以下の手順で環境構築を行います。必要なタイミングで手作業を求められる部分はその都度指示が表示されます。

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
ssh -T git@github.com  # 接続確認

# 6. dotfiles リポジトリをクローン
git clone git@github.com:YOSHIHIDEShimoji/dotfiles-mac.git ~/dotfiles-mac
cd ~/dotfiles-mac

# 7. bootstrap スクリプトを実行（自動リンク & インストール）
./install/bootstrap.sh
```

このスクリプトにより以下が実行される：

* `zsh/links.prop` や `git/links.prop` に基づいて dotfiles を `~` 以下にシンボリックリンク
* `Brewfile` に基づいて CLI / GUI アプリをインストール

---

## 💻 Brewfile でインストールされる主要アプリ

### CLI

```
brew "git"
brew "gh"
brew "fzf"
brew "ripgrep"
brew "bat"
brew "wget"
brew "curl"
brew "jq"
brew "tree"
```

### GUI

```
cask "google-chrome"       # Google Chrome
cask "spotify"             # Spotify
cask "discord"             # Discord
cask "visual-studio-code"  # VSCode
cask "coteditor"           # CotEditor
cask "clipy"               # Clipy
cask "rectangle"           # Rectangle
cask "hiddenbar"           # Hidden Bar
cask "alfred"              # Alfred 5
cask "hammerspoon"         # Hammerspoon
cask "istat-menus"         # iStat Menus
cask "slack"               # Slack
```

※ GUI アプリをすでに手動でインストール済みでも、上書きされることはありません（ただしバージョン差異による警告は出る可能性あり）。

---

## 🧩 手動でインストールが必要なアプリ一覧

以下のアプリは Brew または MAS で提供されていない、あるいは GUI 経由でのインストールが推奨されるため、手動でインストールしてください。

* **Google 日本語入力**
* **Google Drive**
* **Adobe Acrobat Reader**
* **Adobe Creative Cloud**
* **CleanMyMac**
* **AppCleaner**
* **BetterTouchTool**
* **KeyboardCleanTool**
* **Whisper Transcription**
* **MonitorControl Lite**
* **MiniCalendar**
* **Microsoft Word / Excel / PowerPoint**

---

## 🔗 リンク内容（例）

* `~/.zshrc` → `dotfiles-mac/zsh/.zshrc`
* `~/.gitconfig` → `dotfiles-mac/git/.gitconfig`
* `~/.gitignore_global` → `dotfiles-mac/git/.gitignore_global`
