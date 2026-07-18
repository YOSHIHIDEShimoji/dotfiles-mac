# ローカル運用ルール（このマシン / Claude Code 固有）

このファイルには **このマシンで Claude Code を動かすためのローカル運用ルールだけ** を書く。
このリポジトリは public のため、**マシン/アカウント固有の情報（内部ホスト・リモート接続・クラウド認証状態・
プロジェクト名・Vault 実パス等）はここに書かず** `~/.claude/CLAUDE.local.md` に分離する（#30）。
末尾の `@CLAUDE.local.md` でインポートされ、毎セッション読み込まれる。テンプレートは
`claude/CLAUDE.local.md.example`（bootstrap が未存在時にシード）。ssh の `config.local` と同じ型。

**私が誰か・話し方・進め方・価値観など「全体に関わること」は Vault が正典。**（Vault の実パスは CLAUDE.local.md 参照）
SessionStart フックが `_My Context.md` を毎セッション注入するので、話し方の中核はそこから来る。

**二重管理しない** —— グローバルな内容はここに書かず、Vault に書く。ここはローカルのみ。

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

- Skills の実体は `~/dotfiles/claude/skills/` で管理（git 管理対象）
- 新しい skill をインストールするときは `~/dotfiles/claude/skills/` に入れる
- `~/.agents/skills` → `~/dotfiles/claude/skills/`（シンボリックリンク）
- `~/.claude/skills` → `~/.agents/skills`（シンボリックリンク）
- `cc-skills-sync` は廃止済み・使わない
- **第三者スキルも git 管理する**。再インストール可能でも「依存物だから非追跡」にはしない。clone 一発で全環境が揃うこと（オフライン復元・版の固定）を、リポジトリの軽さより優先する
- **第三者スキルの導入は公式リポジトリを `git clone` してファイルを取り込む**（npm 等のインストーラでコード実行しない＝安全機構でブロックされるうえ版が浮く）。例: ui-ux-pro-max は `nextlevelbuilder/ui-ux-pro-max-skill` を clone → `.claude/skills/ui-ux-pro-max/` を skills 配下へコピー
- ただし**同じスキルが環境のプラグインとして常時提供されている場合**（`anthropic-skills:*` 等）は dotfiles に自作コピーを二重に置かず、プラグイン版に一本化する（例: frontend-design / skill-creator は自作コピーを削除しプラグイン版を使う）

## Agents 管理（サブエージェント定義）

- Agents の実体は `~/dotfiles/claude/agents/` で管理（git 管理対象）。`~/.claude/agents` → そこへのシンボリックリンク（`links.prop` に登録済み＝bootstrap が新マシンでも自動リンク）
- **グローバル土台＋プロジェクト自己専用化**方式: エージェント定義は汎用の方法論だけ持ち、プロンプト内で「対象 repo の CLAUDE.md / docs の規約を読んで固有基準を合成せよ」と指示する。より強く縛りたい repo は `.claude/agents/<name>.md` を置けばプロジェクト版が優先される
- **`test-auditor`**（テスト監査・Fable5・readonly）: ロジック変更（lib / actions / API / middleware 等）を伴う merge の**前に必ず**起動し、追加テストの質と漏れ（false confidence）を監査する。blocking が出たらテストを直してから merge。データ・docs のみの変更ではスキップ。起動判断は Claude が行う。モデルは `fable`（引退時は opus → sonnet に降格）

## merge 前の検証（全プロジェクト共通）

1. `npm test` 等の単体テストを**その場で実行して緑を目視**（実装時に通った記録を信頼しない）
2. ロジック変更があれば `test-auditor` で監査 → blocking ゼロを確認
3. それから merge。統合テストは重い場合、スキーマ/アクション層を触ったときのみ merge 前に回し、通常は夜間 CI に任せる

## クラウドサービスの認証・Supabase 等（マシン/アカウント固有）

- ネイティブ CLI/token 優先の原則、認証済みアカウント・org・プロジェクト名などの固有情報は
  `~/.claude/CLAUDE.local.md` に分離した（public リポジトリに晒さないため＝#30）。

## 禁止事項

- GitHubもContributionにclaude codeを含めない
- グローバルの Python 環境を汚さない
- rm コマンドは実行しない。trash -v をつかう。rm コマンドを使うべきだと判断したらユーザに理由を説明したうえで提案する

<!-- マシン/アカウント固有ルールを読み込む（#30）。このファイルは ~/.claude/CLAUDE.md への
     symlink のため、相対 import だと解決先が曖昧になる。絶対パス（~ 展開）で確実に指す。 -->
@~/.claude/CLAUDE.local.md

