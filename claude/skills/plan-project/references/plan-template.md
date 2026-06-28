# Plan template — structure for `docs/plan.md`

Copy this skeleton and fill every section with project-specific content. The
finished `docs/plan.md` is the single artifact a fresh session reads to build the
whole project. Write concretely: real paths, real commands, real decisions. Cut
sections that genuinely don't apply, but never leave a `[TODO]`.

Sections a good plan contains:
1. Context  2. Scope  3. 不変条件 (must-not-break)  4. Services & verified status
5. Branch/Env strategy  6. Design direction  7. 画面構成 (screens & IA)
8. Architecture & data model  9. API/エンドポイント  10. 環境変数
11. Implementation phases  12. File & data locations  13. シード & ハッピーパス検証
14. Test methods  15. Verification & deploy  16. Prerequisites  17. 中断ポイント
18. Risks & mitigations  19. Conventions & secrets  20. Decision Log
21. Done definition & hand-off

---

```markdown
# <Project> 実装プラン  （version / 最終更新日）

## 1. Context（なぜ作るか）
- 解決する課題 / 背景 / 期待する成果。要件があればリンク（例: docs/要件定義.md）。

## 2. スコープ
- v1でやること / やらないこと（明確に）。

## 3. 不変条件（壊してはいけない / must-not-break）
- 実装者が絶対に守るハード制約。プライバシー・セキュリティ・データ寿命など。
- 例:「<値>はクライアント/APIに返さない（write-only）」「<入力>は保存せず破棄」。
- 破ると台無しになるもののみを、検証可能な形で列挙する。

## 4. 使うサービスと確認済み状態
| サービス | 役割 | CLI | 認証/作成可否（実測） |
|---|---|---|---|
| 例: Vercel | ホスティング | vercel | ✅ login済 / プロジェクト作成可 |
| 例: Neon | DB(Postgres) | neonctl | ✅ login済 / プロジェクト作成可 |

## 5. ブランチ・環境運用
| ブランチ | 役割 | 環境 | 固定URL | DB |
|---|---|---|---|---|
| main | 本番 | Production | https://<app>.vercel.app | <prod> |
| develop | 開発・検証 | Preview(固定) | https://<app>-dev.vercel.app | <dev> |
- push対象/`main`マージは要オーナー承認、等の運用ルール。

## 6. デザイン指針
- 採用するデザインソース（例: docs/DESIGN-*.md）と主要トークン。使うUIスキル。

## 7. 画面構成（画面一覧・ナビゲーション）
- ナビ/タブ構成、画面ごとの目的・要素・操作・遷移先、レスポンシブ方針。
- ※ユーザーに提案して合意した内容を反映。

## 8. アーキテクチャ & データモデル
- 構成図（テキスト可）。技術スタック。DBスキーマ（表・列・制約）。主要ロジックは擬似コードで。

## 9. API・エンドポイント一覧（バックエンド有りの場合）
| メソッド/パス | 用途 | 返さない/注意 |
|---|---|---|
| 例: GET /api/x | 一覧取得 | <秘匿フィールド>は返さない |

## 10. 環境変数
| 変数 | 用途 | 環境 | 置き場所 | 例/備考（値は書かない） |
|---|---|---|---|---|
| 例: DATABASE_URL | DB接続 | prod/dev | .env.local + ホスティングenv | 環境別 |

## 11. 実装フェーズ（F0..Fn）
- F0 インフラ: scaffold、サービス作成(prod/dev)、env、スキーマ適用、初期データ、CI、CLAUDE.md。
- F1.. 機能ごとに成果物と完了条件。各フェーズ末でローカル動作確認。最終: main反映→本番、develop用意。

## 12. ファイル・データの場所
- ディレクトリ構成。移動した持ち込みファイルの新パス。機密ファイルの gitignore 状況。

## 13. シードデータ & ハッピーパス検証
- シード: dev DBに入れるテストデータと投入コマンド。
- ハッピーパス: 「この一連が通れば完成」というE2E手順をステップで列挙。

## 14. テスト方法
- 単体: 何を/どのコマンドで。 E2E: 起動方法とブラウザ検証手順（MCP/手動）。データ突合（あれば）。

## 15. 検証・デプロイ
- デプロイ手順と本番/dev URLでの確認コマンド（curl -I 等）。「動いている」シグナル。

## 16. 前提（実装開始前に揃っているもの）
- 必要なCLIログイン・権限・環境変数・シークレット（値は書かない／置き場所だけ）。

## 17. 中断ポイント（自走中に人間が必要な箇所）
- ここだけは実装者が止まってユーザーに依頼する。各項目: 何を/なぜ人間が要るか/何を提示して待つか。
- 例: カスタムドメインのDNS設定、課金プランのアップグレード、本人しか発行できないAPIキー。

## 18. リスクと対策
| リスク | 影響 | 対策/フォールバック |
|---|---|---|
| 例: 依存のデプロイサイズ超過 | デプロイ失敗 | 代替実装に切替 |

## 19. 規約・シークレット・注意
- 秘密情報・個人データはコミットしない（gitignore対象を列挙）。
- コミット規約（ユーザーのグローバル方針に従う：例 Claude Code 署名を含めない）。

## 20. Decision Log（確定した設計判断と理由）
| # | 論点 | 決定 | 理由 |
|---|---|---|---|
| 1 | 例: DBアクセス層 | <決定> | <なぜ> |

## 21. 完成の定義 & ハンドオフ
- 「完成」= 例: 本番URLで主要フローが一通り動く状態。
- 完了時にユーザーへ提示する内容（URL + 共有手順 + テスト手順）。
```

---

## Self-driving checklist (verify before finishing)

A fresh session with ONLY `docs/plan.md` must be able to answer all of these. If
any is "no", the plan is not done.

- [ ] Can it set up every service from zero (which CLI commands, which env vars)?
- [ ] Are all env vars listed (name, scope, where set)?
- [ ] Does it know the exact branch/URL/DB mapping and merge rules?
- [ ] Does it know the design direction, screen composition, and UI skill to use?
- [ ] Are the **不変条件 (must-not-break)** explicit and verifiable?
- [ ] Is the data model / API surface / core logic specified unambiguously?
- [ ] Are phases ordered with clear per-phase "done" conditions?
- [ ] Does it know where every file (incl. moved ones) lives?
- [ ] Are seed data + a happy-path E2E + test/verification steps runnable as written?
- [ ] Are the **中断ポイント** (where to stop for the user) listed?
- [ ] Are risks + fallbacks captured?
- [ ] Are secrets/PII handling, commit conventions, and Decision Log recorded?
- [ ] Is "done" defined, with what to hand back to the user?
