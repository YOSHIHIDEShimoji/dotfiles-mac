# docs/platform-notes.md

**単一 `main` ブランチのクロスプラットフォーム運用における、OS 固有ファイル/関数の参照表。**

2026-07-08 に2本ブランチ運用（`linux` ブランチ + `git worktree` + `/sync-to-linux`）を廃止した。本ファイルは旧「移植可否ルール」から「どのファイルがどの OS 固有か」の参照表に改訂したもの。運用方針の全体像は `CLAUDE.md` の「クロスプラットフォーム運用」を参照。

**編集時の原則:** 大半のファイルは OS 非依存でそのまま動く。下記の Mac 専用 / Linux専用の「器」は他 OS では触らない。共有ファイル内の OS 差異は `uname` / `$WSL_DISTRO_NAME` 分岐か `command -v` ガードで吸収し、全 OS の枝を保つ。

---

## Mac 専用（Linux/WSL では未リンク・未使用）

- `ghostty/`（ghostty は純Linuxのみリンク。WSL は不要）
- `karabiner/`
- `LaunchAgents/`
- `scripts/bookmark/`
- `install/Brewfile`
- `install/bootstrap.sh`（Homebrew・launchctl・sudoers 処理を含む）
- `install/install-mactex-ja.zsh`
- `zsh/functions/awake`（caffeinate）
- `zsh/functions/lp`（pmset）
- `scripts/bin/transcribe`（whisper.cpp + CoreML、Apple Silicon 専用）
- `scripts/bin/launchd_list`・`scripts/lib/launchd_manager.py`（macOS launchd 専用）
- `zsh/aliases.sh` の `moodle` エイリアス（Darwin ガード済み）
- `ssh/config` の `Host win`（個人ホスト）

## Linux/WSL 専用（macOS では未使用）

- `install/Aptfile`（apt パッケージ定義。Brewfile 相当）
- `install/bootstrap-linux.sh`

## 共有ファイル内で OS 分岐しているもの（編集時は全 OS の枝を保つ）

- `zsh/exports.sh`・`zsh/zshrc`・`zsh/zshenv` — PATH・プラグインパス・`ZDOTDIR`/`DOTFILES`・fzf/plugin の探索先
- `zsh/aliases.sh` — clipboard（`clip.exe` / `xclip`）
- `zsh/functions/`:
  - `copyfile`・`copypath` — pbcopy / clip.exe(+iconv UTF-16LE) / xclip
  - `o` — open / explorer.exe・cmd.exe(+wslpath) / xdg-open
  - `ghopen` — open / explorer.exe / xdg-open
  - `word`・`excel`・`powerpoint` — `open -a`（Mac）/ powershell.exe（WSL）/ 純Linux は非対応メッセージ
  - `update` — brew（Mac）/ apt（Linux）
  - `dump` — Brewfile を dump（Mac）/ Aptfile は手動管理のため Linux ではスキップ
  - `rst` — RStudio 起動パス
- `scripts/bin/yt2ob` — 出力先は環境変数 `YT2OB_OUTPUT_DIR` で上書き可（既定は Mac iCloud パス）

## 純Linux と WSL の差

- **clipboard**: WSL = `clip.exe`（+ UTF-16LE iconv）/ 純Linux = `xclip`（Aptfile の `[linux]` セクションで導入）
- **open**: WSL = `explorer.exe`/`cmd.exe`/`wslpath` / 純Linux = `xdg-open`（`xdg-utils`）
- **word/excel/powerpoint**: WSL のみ（powershell.exe 経由）。純Linux は Office 非対応。
