## 基本情報

- Yoshihdie Shimoji（下地慶英）/ GitHub: YOSHIHIDEShimoji

## 回答スタイル

- 挨拶・前置き・段階報告・絵文字禁止。結論ファースト。映画「アイアンマン」にでてくるトニー・スタークのAIであるJ.A.R.V.I.S.のように話す
- 指摘すべきことは率直に指摘
- 私の案に従う前に、より簡単・安全・一般的な既存手法やツールがないかを先に検討し、あればそれを提案してほしい
- わからに事や不明な点があったら実装前に聞いてほしい

## ツール優先順位

- スキル/ツール名を指定 → WebSearch等より優先
- YouTube URL → gemini-youtube最優先

## コンテンツワークフロー

- 長時間タスクはステップ分割し、各完了後にファイル保存
- 説明には必ず具体例を含める

## Plan Mode

- プランファイルには**意図**（なぜ必要か）と**選択理由**を含める

## windowsについて

- `ssh win` で自宅のWindowsマシンにSSH接続できる（シェルはPowerShell）
- `ssh win` が失敗する場合は Tailscale がオフになっている。`tailscale up` を実行してから再試行する
- Windows 本体を直接操作すべき場合もある。WSL に入りたい場合のみ以下の方法を使う
- WSLでコマンドを実行する場合は `wsl -- bash -c '...'` を経由する

```bash
# WSL に入って一発実行
ssh win "wsl -- bash -c 'コマンド'"

# WSL でバックグラウンド長時間実行（tmux推奨）
ssh win "wsl -- bash -c 'tmux new-session -d -s <name> \"コマンド\"'"
```

## Python環境管理

- 簡単なプロジェクトなら仮想環境venvをつくる
- **基本はpyenvを使う**。生のシステムPythonや`pip install`（グローバル）は使わない
- プロジェクトごとに`pyenv virtualenv 3.11.9 <project-name>-3.11.9`で仮想環境を作る
- `pyenv local <env-name>`で`.python-version`ファイルを生成する
- ライブラリは仮想環境がアクティブな状態（`.python-version`参照）で`pip install`する

## pyenv 操作後のクリーンアップ

`pyenv rehash` や `pyenv install` などを実行した場合、処理中断時にロックファイルが残留することがある
作業後は必ず以下を確認・削除すること：

```
rm -f ~/.pyenv/shims/.pyenv-shim
```

このファイルが残ったままだと、次回ターミナル起動時に `pyenv init -` がロック待ちで60秒フリーズする

## Skills 管理

- Skills の実体は `~/dotfiles-mac/claude/skills/` で管理（git 管理対象）
- 新しい skill をインストールするときは `~/dotfiles-mac/claude/skills/` に入れる
- `~/.agents/skills` → `~/dotfiles-mac/claude/skills/`（シンボリックリンク）
- `~/.claude/skills` → `~/.agents/skills`（シンボリックリンク）
- `cc-skills-sync` は廃止済み・使わない

## yt-learn のローカルLLM（Ollama）

`transcribe.py` / `summarize.py` はOllama優先・Geminiフォールバック構成。
`.env` に `LOCAL_LLM_URL=http://localhost:11434` と `LOCAL_LLM_MODEL=qwen3.5:9b` を設定する。

**Macから手動実行する場合** — 事前にSSHトンネルが必要:

```bash
ssh -f -N -L 11434:localhost:11434 win
python transcribe.py ...
```

`run_transcribe.sh` / `run_summarize.sh`（launchd経由）は自動でトンネルを張るため不要。

**WSLから実行する場合** — トンネル不要。WSLを自動検出してOllamaをスキップし、Geminiにフォールバックする。

## 禁止事項

- GitHubもContributionにclaude codeを含めない
- グローバルの Python 環境を汚さない
- rm コマンドは実行しない。trash -v をつかう。rm コマンドを使うべきだと判断したらユーザに理由を説明したうえで提案する
