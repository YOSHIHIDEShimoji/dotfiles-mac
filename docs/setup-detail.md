# bootstrap.sh の仕組み

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
