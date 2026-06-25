---
name: issue-triage
description: GitHub Issue トリアージスキル。Issue を分析してラベルを付与する。ユーザーが「issue をトリアージして」「ラベルを付けて」「#N をトリアージして」などと言ったときに使用する。Issue番号を指定しない場合はラベルが振られていない全Issueが対象。テックリードとして振る舞い、Priority / Risk / Impact / Area の4カテゴリのラベルを付与する。既存ラベルが誤っていれば修正する。出力は最終成果物（ラベル付与）のみ。
---

# Issue Triage

テックリードとして振る舞い、Issue を分析して適切なラベルを付与する。

## 前提

- `gh` CLI でラベル操作する
- 説明・分析結果は**出力しない**。成果物はラベル付与のみ
- 理由を聞かれた場合のみ説明する

## ラベル定義

詳細な基準は [references/labels.md](references/labels.md) を参照。

| カテゴリ | ラベル一覧 |
|---|---|
| Priority | `P0-critical` `P1-high` `P2-medium` `P3-low` |
| Risk | `risk-low` `risk-medium` `risk-high` |
| Impact | `impact-user-blocking` `impact-user-visible` `impact-internal` |
| Area | `area-frontend` `area-backend` `area-database` `area-auth` `area-infra` `area-email` `area-seo` |

Area は複数付与可。Priority / Risk / Impact は各1つ。

## 手順

### 1. 対象 Issue を決定

Issue番号を指定された場合はその Issue のみ。**指定がない場合はラベルなしの全 Issue が対象。**

```bash
# ラベルなし Issue を全件取得
gh issue list --limit 100 --json number,title,labels | jq '[.[] | select(.labels | length == 0)]'
```

### 2. Issue を取得・分析

```bash
gh issue view <N> --json title,body,labels,comments
```

分析時に考慮する情報（可能な範囲で）:
- リポジトリ構造・既存 Issue との依存関係
- 実装状況（コード・マイグレーション・スキーマ変更の有無）
- ユーザー影響・変更リスク

### 3. ラベルが存在しなければ作成

```bash
# ラベル一覧を確認
gh label list

# 存在しないラベルを作成（color は references/labels.md を参照）
gh label create "P1-high" --color "e11d48"
```

### 4. ラベルを付与・修正

```bash
# ラベルを追加
gh issue edit <N> --add-label "P1-high,risk-medium,impact-user-visible,area-frontend"

# 誤ったラベルを除去してから追加（カテゴリ内で1つに絞る場合）
gh issue edit <N> --remove-label "P2-medium" --add-label "P1-high"
```

複数 Issue の場合はステップ2〜4を繰り返す。

### 5. 完了

全 Issue のラベル付与が終わったら、**優先度の高い順に上位3件を出力する。**

```
## 対応優先度 Top 3

1. #N タイトル — P0-critical / risk-high / impact-user-blocking
2. #M タイトル — P1-high / risk-medium / impact-user-visible
3. #L タイトル — P1-high / risk-low / impact-internal
```

Priority の順位: P0-critical > P1-high > P2-medium > P3-low。
同 Priority 内では risk-high > risk-medium > risk-low を次点基準にする。
