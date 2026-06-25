# ラベル定義・基準・カラー

## Priority

| ラベル | Color | 基準 |
|---|---|---|
| `P0-critical` | `b91c1c` | サービス停止・データ損失・セキュリティ問題・緊急対応が必要 |
| `P1-high` | `e11d48` | ユーザー価値が高い・重要な不具合・早期対応が望ましい |
| `P2-medium` | `f97316` | 一般的な機能追加・改善要望 |
| `P3-low` | `94a3b8` | 将来的な改善・緊急性の低い機能 |

## Risk

| ラベル | Color | 基準 |
|---|---|---|
| `risk-low` | `4ade80` | UI変更・テキスト変更・軽微な表示変更 |
| `risk-medium` | `fbbf24` | ビジネスロジック変更・API変更・権限変更 |
| `risk-high` | `dc2626` | DBスキーマ変更・認証変更・データ移行・本番データへの影響 |

## Impact

| ラベル | Color | 基準 |
|---|---|---|
| `impact-user-blocking` | `7c3aed` | 利用不能・データ破損・主要機能停止 |
| `impact-user-visible` | `a78bfa` | ユーザー体験に直接影響 |
| `impact-internal` | `cbd5e1` | リファクタリング・CI/CD・開発環境改善・保守性向上 |

## Area

| ラベル | Color | 対象 |
|---|---|---|
| `area-frontend` | `38bdf8` | UI・画面・スタイル |
| `area-backend` | `0284c7` | サーバーロジック・API |
| `area-database` | `7e22ce` | スキーマ・マイグレーション・クエリ |
| `area-auth` | `be185d` | 認証・セッション・権限 |
| `area-infra` | `374151` | Vercel・CI/CD・環境変数・ドメイン |
| `area-email` | `059669` | メール送信・テンプレート |
| `area-seo` | `d97706` | メタタグ・OGP・サイトマップ |
