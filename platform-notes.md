# platform-notes.md

`/sync-to-linux` スキルが linux ブランチへの移植可否を判断するためのルール定義。

---

## Mac専用（linux ブランチに移植しない）

- `ghostty/`
- `karabiner/`
- `LaunchAgents/`
- `scripts/bookmark/`
- `install/Brewfile`
- `install/bootstrap.sh`（Homebrew・launchctl・sudoers処理を含む）
- `zsh/functions/awake`（caffeinate）
- `zsh/functions/lp`（pmset）
- `zsh/functions/update`（brew）
- `zsh/functions/dump`（brew bundle）
- `zsh/exports.sh` の Homebrew・MacTeX・VSCode・Java パス
- `zsh/aliases.sh` の `moodle`

---

## WSL・Linux共通（linux ブランチに移植する）

- `zsh/functions/` の大部分（`mkcd`, `cl`, `gbd`, `ghopen`, `c`, `cm`, `rr`, `zsh_stats`, `newtex`, `copyfile`, `copypath`, `word2ref` 等）
- `git/`
- `vscode/`（リンク先パスは linux ブランチで書き換え済み）
- `scripts/ppdf/`
- `scripts/bin/`
- `templates/`
- `platform-notes.md`

---

## WSL専用（純 Linux では使用不可）

- `zsh/functions/word`（powershell.exe 経由で Word を起動）
- `zsh/functions/excel`（powershell.exe 経由で Excel を起動）
- `zsh/functions/powerpoint`（powershell.exe 経由で PowerPoint を起動）
- `aliases.sh` の `copy='clip.exe'` / `paste='powershell.exe ...'`
- `functions/o` の `explorer.exe` / `cmd.exe /c start` パス

---

## 純 Linux専用（WSL では使用しない）

- `aliases.sh` の `copy='xclip ...'` / `paste='xclip ...'`
- `functions/o` の `xdg-open` パス
