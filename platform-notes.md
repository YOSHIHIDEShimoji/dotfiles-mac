# platform-notes.md

このファイルは、AI（Claude Code）と人間の両方が読む「移植ルール仕様書」です。
`/sync-to-linux` スキルが dotfiles-linux（linux ブランチ）へ移植する際に参照し、除外対象を判断します。

---

## Mac専用 — Linux/WSL には移植しない

### システム・OS固有コマンド
- `caffeinate` — macOSのスリープ防止コマンド（`awake` 関数で使用）
- `pmset` — macOSの電源管理コマンド（`lp` 関数で使用）
- `open` / `open -a` — macOS専用のファイル・アプリ起動コマンド（`o`, `excel`, `word`, `powerpoint`, `newtex` 等で使用）
- `pbcopy` / `pbpaste` — macOSのクリップボードコマンド（`copyfile`, `copypath` 関数で使用）

### macOS固有の関数（zsh/functions/）
- `awake` — `caffeinate` 依存のためLinux/WSL不可
- `lp` — `pmset` 依存のためLinux/WSL不可
- `dump` — `brew bundle` / `brew` 依存。Linux に Homebrew は原則使わない
- `update` — `brew update && brew upgrade` 依存

### WSLには移植するが、純Linuxには移植しない（zsh/functions/）
- `word` / `excel` / `powerpoint` — WSL では Windows の Office アプリを `powershell.exe` 経由で起動可能。純 Linux には Office がないため不要。OS 判定（`$WSL_DISTRO_NAME`）を追加して移植。

### OS判定でクロスプラットフォーム対応済みの関数（zsh/functions/）
- `o` — macOS は `open`、WSL は `explorer.exe`（`wslpath -w` でパス変換）、純 Linux は `xdg-open`。3分岐 OS 判定で実装済み。

### Homebrew（macOS用パッケージマネージャ）
- `install/Brewfile` — Homebrew専用。Linux には移植しない（apt で代替）
- `exports.sh` の Homebrew PATH（`/opt/homebrew/bin`, `/opt/homebrew/sbin`）
- `zshrc` の `$(brew --prefix)/share/...` を使ったプラグインsource

### macOSシステムパス
- `/opt/homebrew/...` — Apple Silicon Homebrew
- `/Library/TeX/texbin` — MacTeX
- `/Applications/Visual Studio Code.app/Contents/Resources/app/bin` — macOS VSCode
- `/opt/homebrew/opt/openjdk@17/bin` — Homebrew Java
- `/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin` — macOS基本PATH（Linuxでは `/usr/local/bin:/usr/bin:/bin`）

### macOS固有ディレクトリ・設定
- `LaunchAgents/` ディレクトリ全体 — macOS launchd 専用
- `karabiner/` ディレクトリ全体 — Karabiner-Elements は macOS専用キーリマップツール
- `ghostty/` ディレクトリ全体 — Ghostty は macOS（および Linux）向けターミナル。ghostty/links.prop のパスが macOS 固有（`~/Library/Application Support/com.mitchellh.ghostty/`）のため linux ブランチには移植しない
- `vscode/links.prop` の `$HOME/Library/Application Support/Code/User/settings.json` — macOS の VS Code 設定パス。Linux では `~/.config/Code/User/settings.json` を使用するため linux ブランチの `vscode/links.prop` は別途定義が必要
- `scripts/bookmark/` — `open -na "Google Chrome"` macOS 固有。Linux では別途 CLI で代替

### bootstrap.sh のmacOS固有処理
- LaunchAgents の登録・`launchctl load`
- `sudoers` への `pmset` 無パスワード設定
- VSCode拡張機能のインストール（`code --install-extension`）は共通で使えるが、Linuxでのパスが異なる点に注意

---

## Linux/WSL専用 — Mac には移植しない

### クリップボード
- `xclip -selection clipboard` または `wl-copy`（純Linux）
- `clip.exe`（WSL固有。`/proc/version` に "microsoft" が含まれる場合）

### パッケージ管理
- `apt` / `apt-get` — Linux専用。`install/bootstrap-linux.sh` で使用
- `apt` によるパッケージリスト — Homebrew の Brewfile に相当するが別ファイルとして管理

### シェル切り替え
- `chsh -s $(which zsh)` — Linux では zsh がデフォルトでない環境が多い。bootstrap-linux.sh で必須手順として実施

### WSL固有
- `clip.exe` — Windows クリップボードへのパイプ
- `explorer.exe` — Windows エクスプローラを開く
- `/proc/version` に "microsoft" を含む = WSL環境の判定条件

---

## クロスプラットフォーム対応（移植時にOS判定を追加）

以下は移植対象だが、OS差異を `uname` や `$WSL_DISTRO_NAME` による if 文で吸収する：

- `exports.sh` のPATH設定（基本PATH部分）
- `aliases.sh` の汎用エイリアス（`l`, `ll`, `grep`, `..` 等）
- `zshrc` のプラグインsource（Homebrewではなく apt インストールパスに変更）
- `copyfile` / `copypath`（クリップボードコマンドをOS判定で切り替え）
- `ghopen`（すでにOS判定あり。そのまま移植可）
- `c`（Cコンパイル実行関数。`$OSTYPE` 判定あり。そのまま移植可）
- `newtex`（`open` 部分のみOS判定追加で移植可）
- `zshrc` の fzf / zoxide 統合（インストール済みなら動く）
- `zshrc` の pyenv 統合（インストール済みなら動く）
- `web_search`（`open_command` をOS対応版に変更）

---

## 備考

- このファイルは人間が手動で更新する。新しいMac専用機能を追加したら「Mac専用」セクションに追記すること。
- 判断に迷う場合は「移植対象」として扱い、OS判定で動的に吸収する方針を優先する。
