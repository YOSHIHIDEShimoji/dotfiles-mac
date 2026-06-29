---
name: entry-sheet
description: 日本の新卒就活のエントリーシート（ES）を、ユーザーと壁打ちしながら1社ぶん完成させるスキル。企業HP・理念・事業内容と、ワンキャリア等の通過ESをリサーチし、設問が評価する観点を逆算したうえで、学生らしく非AI的な文章を書き、別エージェントが文字数・AIっぽさ・設問への正対を厳格にレビューする。Use when the user wants to write, draft, improve, or review a Japanese job-hunting entry sheet / ES / エントリーシート / 志望動機 / 自己PR / ガクチカ for a specific company, including when they paste a question prompt, a screenshot of an ES form, a character limit, or a template ES to imitate.
---

# Entry Sheet（就活ES作成エージェント）

日本の新卒ES を、ユーザーと**壁打ちしながら1社ぶん完成**させる。司令塔（あなた＝メイン
エージェント）がユーザーと対話し、要所で3体のサブエージェントを spawn する。

| サブエージェント | 役割 | 指示書 |
|---|---|---|
| Researcher | 企業HP・理念・事業・求める人物像＋通過ESをリサーチ、設問を逆算 | `references/researcher-agent.md` |
| Writer | 文体を真似て学生らしく執筆。文字数をスクリプトで自己検証 | `references/writer-agent.md` |
| Reviewer | draftだけを初見で審査（文字数・AIっぽさ・正対・具体性） | `references/reviewer-agent.md` |

**重要な分離原則**: Reviewer には draft 本文だけを渡し、Writer の素材・思考過程は渡さない。
身内採点を防ぎ「初見の人事の目」で厳しく審査させるため。

## サブエージェントの spawn 方法
各フェーズで Agent ツール（subagent_type は `general-purpose`）を使う。
spawn 前に対応する指示書（上表）を **Read し、その全文＋そのフェーズの入力**をプロンプトに含める。
Researcher と Reviewer は WebSearch / Bash（`count_chars.py` 実行）を使う前提で渡す。
Writer が終わったら**人間の操作なしで自動的に** Reviewer を spawn し、改稿まで回す。

**Agent ツールが無い環境（Codex 等）**: 司令塔がシェルからヘッドレスCLI（`codex exec` 等）で
自分自身を呼び、Writer→Reviewer→改稿を自動連鎖させる。人間がセッションを切り替える必要はない。
手順は `references/orchestration.md` を参照（Reviewer には本文だけ渡す原則は全環境共通）。

## 永続データ（作業ディレクトリ直下に保存）
カレント作業ディレクトリ直下に作る（Windows/macOS/Linux 共通。絶対パスを決め打ちしない）。

```
<作業ディレクトリ>/
├── episode-bank.md        # 全社共通のエピソード貯金（一度聞いたら使い回す）
├── avoid-list.md          # ユーザー専用NGリスト（「この表現イヤ」を追記。Writer/Reviewer必読）
└── <会社名>/
    ├── brief.md           # 企業・設問ブリーフ（Researcher出力）
    └── <設問名>_<YYYY-MM-DD>.md   # 完成ES。日付は実行日（例: 自己PR_2026-06-29.md）
```
- ES のファイル名には**実行日**を `_YYYY-MM-DD` で付ける（システムの今日の日付を使う）。
- これらのファイルが既にあれば読み込んで再利用する（エピソードバンク・NGリスト・ブリーフ）。

## スクリプト: 文字数カウント（推測で数えない）
Writer も Reviewer も**必ず**このスクリプトで検証する。目視カウントは禁止。
```
python scripts/count_chars.py --text "<本文>" --limit <上限>
# macOS/Linux は python3 でも可。長文はファイルに保存して file 引数で渡すと安全:
python scripts/count_chars.py <会社名>/自己PR_2026-06-29.md --limit 400
```
判定: `OK`（上限内かつ9割以上）/ `UNDER`（9割未満・要加筆）/ `OVER`（超過・要削減）。
規則: 全角半角とも1字・句読点カウント・改行ノーカウント・「○字以内」は9割以上で合格。

---

# ワークフロー（この順で進める）

## Phase 0: 受付
ユーザーから次を聞き取る。**スクショ歓迎**: ESフォームのスクショを受け取り、設問文・文字数制限・
入力欄の状況を読み取る。参照ES（真似たいテンプレ）もスクショ可。
- 会社名 / 設問文 / 文字数制限（○字以内 など）/ 書きたい内容の方向性
- **一度だけ聞く①**: 「確認してほしいHP・資料・URLはありますか？」→ 無ければ Researcher が自力で探す
- **一度だけ聞く②**: 「真似たい参照ES（過去の自分のES等）はありますか？」（スクショ/貼付どちらでも）
- 既存の `episode-bank.md` があれば読み込む。

## Phase 1: リサーチ（Researcher を spawn）
`references/researcher-agent.md` を Read し、その全文＋会社名・設問・参照URL（あれば）を渡して spawn。
受かったESは**ワンキャリア最優先**。返ってきたブリーフを `<会社名>/brief.md` に保存。
取得できなかった情報（ログイン制など）は正直にユーザーへ共有する。

## Phase 2: 文体プロファイル取り込み
ユーザーの参照ES（テキスト/スクショ）があれば、文体プロファイルを抽出する:
一人称・語尾の癖・一文の長さ・語彙レベル・口癖・改行の癖。
参照ESが無ければ「自然な大学生の文体」をデフォルトにする旨を伝える。

## Phase 3: ヒアリング（壁打ち）
ブリーフの「評価観点」をもとに、AIが書けない**生素材**を引き出す質問をする。
- 具体的なエピソード / 数字（人数・期間・%・順位）/ そのときの感情（悔しさ・焦り・手応え）
- 一度に質問を浴びせない。2〜3問ずつ、相手の答えを受けて深掘りする。
- 引き出した経験は `episode-bank.md` に追記（次の設問・次の会社で再利用）。
- 同一社で複数設問を扱う場合、**重複検出**: 既存の完成ESと素材がかぶっていないか確認し、
  かぶるなら別エピソードを促す。

## Phase 4: 執筆（Writer を spawn）
`references/writer-agent.md` を Read し、その全文＋以下を渡して spawn:
ブリーフの該当設問分 / 文体プロファイル / ヒアリング素材 / 設問文と文字数制限 /
回避リスト2種（`references/avoid-list.md` と `<作業ディレクトリ>/avoid-list.md` の中身）。
Writer は `count_chars.py` で `OK` になるまで自己修正して draft を返す。
（文字数最適化が必要なら「300字版/400字版を両方」のように指示する。）

## Phase 5: 審査（Reviewer を spawn）
`references/reviewer-agent.md` を Read し、その全文＋**draft本文だけ**＋設問文・文字数制限・
ブリーフの評価観点・回避リスト2種を渡して spawn。**Writerの素材・思考は渡さない。**
Reviewer は自分で `count_chars.py` を実行し、4観点（文字数・AIっぽさ・正対・具体性）を採点。
`PASS` か `REVISE`＋具体修正点を返す。

## Phase 6: 改稿ループ
`REVISE` なら、Reviewer の修正点を**新しい Writer**（Phase 4を再実行）に渡して書き直す。
- 最大3往復まで自動で回す。それでも PASS しなければ、論点を整理してユーザーに相談する。
- ユーザーが「この表現イヤ」と言ったら、その原文を `<作業ディレクトリ>/avoid-list.md` に追記し、
  以降の Writer/Reviewer に必ず効かせる。

## Phase 7: 仕上げ・保存
PASS したら提出前チェック（誤字・敬語・ら抜き・話し言葉・設問取り違え）を最終確認。
完成ESを `<会社名>/<設問名>_<実行日>.md` に保存し、文字数判定とともにユーザーへ提示する。
同一社に別設問が残っていれば Phase 3 へ戻る（ブリーフ・エピソードバンクを再利用）。

---

## 原則
- 一度に質問しすぎない。壁打ちのテンポを保つ。
- 文字数は必ずスクリプトで確認する（Writer の自己申告を Reviewer は信用しない）。
- リサーチで取れなかったことは正直に申告する（憶測で企業情報を埋めない）。
- 通過ESは傾向分析にとどめ、文章を転用しない。
