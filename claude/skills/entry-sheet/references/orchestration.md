# 自動オーケストレーション（環境別）

Writer↔Reviewer のループは **人間の操作なし**で自動連鎖させる。
司令塔は Phase0–3（受付・リサーチ・ヒアリング）を人間と対話し、Phase4–6 の
執筆→審査→改稿は自分でサブ実行を呼んで回す。

**全環境共通の鉄則**: Reviewer には **draft 本文だけ**を渡す（Writer の素材・思考は渡さない）。
これが「初見の人事の目」という設計の肝。サブ実行は毎回**新しいコンテキスト**で動くので、
必要な情報（指示書の全文・設問・文字数・素材・回避リスト）はプロンプトに全部入れる。

## Claude Code
司令塔が `Agent` ツール（subagent_type `general-purpose`）で Writer・Reviewer を spawn する。
SKILL.md 本体の手順どおり。これだけで自動連鎖し、人間は介在しない。

## Codex CLI（`codex exec`）
Codex には `Agent` ツールが無いが、司令塔がシェルで自分自身をヘッドレス起動できる。
これでセッション切り替え不要のまま自動連鎖を実現する。

ループの中身（司令塔が順に実行）:
```
# 1) 執筆: Writer をヘッドレスで呼ぶ（指示書全文＋入力を渡す）
codex exec "$(cat references/writer-agent.md)
---入力---
設問: <設問文> / 文字数上限: <N>
文体プロファイル: <...>
素材(エピソード/数字/感情): <...>
回避リスト: $(cat references/avoid-list.md) と $(cat avoid-list.md 2>/dev/null)
本文だけを返せ。" > /tmp/draft.txt

# 2) 文字数チェック（決定的）
python scripts/count_chars.py /tmp/draft.txt --limit <N>

# 3) 審査: Reviewer をヘッドレスで呼ぶ（draft本文「だけ」＋評価観点を渡す）
codex exec "$(cat references/reviewer-agent.md)
---審査対象---
設問: <設問文> / 文字数上限: <N>
評価観点(brief.mdより): <...>
回避リスト: $(cat references/avoid-list.md) と $(cat avoid-list.md 2>/dev/null)
本文:
$(cat /tmp/draft.txt)" > /tmp/review.txt

# 4) REVISE なら修正点を付けて 1) に戻る。最大3回。PASS で確定。
```

注意:
- 非対話実行ではコマンド承認やサンドボックスの設定が必要なことがある。`codex exec --help` で
  自動承認/サンドボックスのフラグを確認して付ける。
- `codex exec` は標準出力に最終結果を出す。中間ログが混ざる場合は本文だけ抽出する。
- ネスト実行のコスト・所要時間に注意（3往復＝最大6回のサブ実行）。

## その他の汎用エージェント / CLI
ヘッドレス実行できるものなら同じ発想で連鎖できる:
- Claude CLI: `claude -p "<プロンプト>"`
- その他: 各CLIの非対話モード、または LLM API を叩く小さなドライバスクリプト

いずれも「Reviewer には本文だけ」「必要情報は毎回プロンプトに全部入れる」を守れば、
人間がセッションを切り替えずに Writer→Reviewer→改稿を自動で回せる。
