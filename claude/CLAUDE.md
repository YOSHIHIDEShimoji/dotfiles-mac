# ローカル運用ルール（このマシン / Claude Code 固有）

このファイルには **このマシンで Claude Code を動かすためのローカル運用ルールだけ** を書く。

**私が誰か・話し方・進め方・価値観など「全体に関わること」は Vault が正典。**
→ `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Yoshihide's context vault/04_Context/`
（話し方・進め方・ツール優先順位＝`_My Context.md` の「Claudeへの標準指示」／レポート文体＝`Voice & Messaging.md`／働き方＝`Working Style.md`／価値観＝`Philosophy & Values.md`）。
SessionStart フックが `_My Context.md` を毎セッション注入するので、話し方の中核はそこから来る。

**二重管理しない** —— グローバルな内容はここに書かず、Vault に書く。ここはローカルのみ。

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
- **第三者スキルも git 管理する**。再インストール可能でも「依存物だから非追跡」にはしない。clone 一発で全環境が揃うこと（オフライン復元・版の固定）を、リポジトリの軽さより優先する
- **第三者スキルの導入は公式リポジトリを `git clone` してファイルを取り込む**（npm 等のインストーラでコード実行しない＝安全機構でブロックされるうえ版が浮く）。例: ui-ux-pro-max は `nextlevelbuilder/ui-ux-pro-max-skill` を clone → `.claude/skills/ui-ux-pro-max/` を skills 配下へコピー
- ただし**同じスキルが環境のプラグインとして常時提供されている場合**（`anthropic-skills:*` 等）は dotfiles に自作コピーを二重に置かず、プラグイン版に一本化する（例: frontend-design / skill-creator は自作コピーを削除しプラグイン版を使う）

## クラウドサービスの認証（ネイティブCLI/トークン優先）

- **原則**: 各クラウドサービスは、**そのサービス固有のCLI/API/tokenで直接**操作する。
  別サービスの統合/Marketplace経由でプロビジョンしない（例: Neon を `vercel integration add neon`
  で作らない）。代理経由で作ると**代理（Vercel等）所有になり、自分のアカウントの一覧に出ず、
  ネイティブCLIで管理できなくなる**（後で移行する羽目になる）。
- **新規サービスを使うときも同じ**: まず「そのサービスのネイティブCLIや既発行のAPIキー/トークンで
  認証済みか」を確認し、認証済みならそれを直接使う。無ければユーザーに発行/ログインを依頼してから使う。
- **Vercel**: `vercel` CLI ログイン済み（`vercel whoami` で確認）。プロジェクト作成・env管理・
  デプロイは `vercel` で直接行う。
- **Neon**: `neonctl` ログイン済み（`neonctl me` で確認）。**Vercel経由で作らない**。プロジェクトは
  自分の個人org に作る（Neonダッシュボードの一覧に出る）。本番/開発は1プロジェクトの
  `main`/`develop` ブランチで分け、各環境の `DATABASE_URL` を手動配線（`--pooled` URI）。
- 注意: `vercel env rm <NAME> <env>` は1エントリ全環境分を消すことがある。env別に値を変えるときは
  「全削除→production/preview/development を明示add」。本番値は触る前にバックアップ。

## Supabase CLI

- macOS キーチェーンに認証済み（`supabase projects list` で確認可能）
- `takeda-todo` と `past-exam-app` の2プロジェクトにアクセス可能
- DBマイグレーション適用・SQL実行・ログ確認等が CLI から直接操作できる

## 禁止事項

- GitHubもContributionにclaude codeを含めない
- グローバルの Python 環境を汚さない
- rm コマンドは実行しない。trash -v をつかう。rm コマンドを使うべきだと判断したらユーザに理由を説明したうえで提案する
