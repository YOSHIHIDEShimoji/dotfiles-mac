# Plan template — structure for `docs/plan.md`

Copy this skeleton and fill every section with project-specific content. The
finished `docs/plan.md` is the single artifact a fresh session reads to build the
whole project. Write concretely: real paths, real commands, real decisions. Cut
sections that genuinely don't apply, but never leave a `[TODO]`.

Table of contents of what a good plan contains:
1. Context  2. Scope  3. Services & verified status  4. Branch/Env strategy
5. Design direction  6. Architecture & data model  7. Implementation phases
8. File & data locations  9. Test methods  10. Verification & deploy
11. Prerequisites  12. Conventions & secrets  13. Done definition & hand-off

---

```markdown
# <Project> 実装プラン

## 1. Context（なぜ作るか）
- 解決する課題 / 背景 / 期待する成果。要件ドキュメントがあればリンク（例: docs/要件定義.md）。
- 最重要制約（あれば）— 設計を縛る前提を1行で。

## 2. スコープ
- v1でやること（箇条書き） / やらないこと（明確に）。

## 3. 使うサービスと確認済み状態
| サービス | 役割 | CLI | 認証/作成可否（実測） |
|---|---|---|---|
| 例: Vercel | ホスティング | vercel | ✅ login済 / プロジェクト作成可 |
| 例: Neon | DB(Postgres) | neonctl | ✅ login済 / プロジェクト作成可 |
- 各サービスのアカウント・組織・既存リソースのメモ。

## 4. ブランチ・環境運用
| ブランチ | 役割 | 環境 | 固定URL | DB |
|---|---|---|---|---|
| main | 本番 | Production | https://<app>.vercel.app | <prod> |
| develop | 開発・検証 | Preview(固定) | https://<app>-dev.vercel.app | <dev> |
- リモートに push するブランチ / `main` マージは要オーナー承認 等の運用ルール。
- 固定dev URL・プレビュー保護の扱い・DBブランチの対応。

## 5. デザイン指針
- 採用するデザインソース（例: docs/DESIGN-*.md）と主要トークン（色・角丸・フォント代替）。
- 使うUIスキル（例: ui-ux-pro-max を各UIフェーズで使用）。

## 6. アーキテクチャ & データモデル
- 構成図（テキストで可）。技術スタック。
- DBスキーマ（テーブル・列・制約）。公開APIで返さないフィールド等のルール。
- 主要アルゴリズム/ロジックは擬似コードで。

## 7. 実装フェーズ（F0..Fn）
- F0 インフラ: scaffold、サービス作成（prod/dev）、env、スキーマ適用、初期データ投入、CI、CLAUDE.md。
- F1.. 機能ごとに、成果物と完了条件を明記。各フェーズ末でローカル動作確認。
- 最終: main へ反映→本番稼働、develop 用意。

## 8. ファイル・データの場所
- 主要ディレクトリ構成。
- 移動した持ち込みファイルの新パス（例: data/roster.txt, docs/DESIGN-*.md）。
- 機密ファイルの gitignore 状況。

## 9. テスト方法
- 単体: 何を、どのコマンドで（例: ロジックの確定例を再現するテスト）。
- E2E: 起動方法（例: vercel dev / npm run dev）とブラウザ検証手順（MCP/手動）。
- データ突合（あれば既存ツール出力との一致確認）。

## 10. 検証・デプロイ
- デプロイ手順と本番/dev URLでの確認コマンド（curl -I 等）。
- 「動いている」と判断する具体的シグナル。

## 11. 前提（実装開始前に揃っている必要があるもの）
- 必要なCLIログイン・権限・環境変数・シークレット（値はここに書かない／置き場所だけ）。

## 12. 規約・シークレット・注意
- 秘密情報・個人データはコミットしない（gitignore対象を列挙）。
- コミット規約（ユーザーのグローバル方針に従う：例 Claude Code 署名を含めない）。
- その他の落とし穴。

## 13. 完成の定義 & ハンドオフ
- 「完成」= 例: 本番URLにアクセスすると主要フローが一通り動く状態。
- 朝/完了時にユーザーへ提示する内容（URL + 共有手順 + テスト手順）。
```

---

## Self-driving checklist (verify before finishing)

A fresh session with ONLY `docs/plan.md` must be able to answer all of these. If
any is "no", the plan is not done.

- [ ] Can it set up every service from zero (which CLI commands, which env vars)?
- [ ] Does it know the exact branch/URL/DB mapping and merge rules?
- [ ] Does it know the design direction and which UI skill to use?
- [ ] Is the data model / core logic specified unambiguously?
- [ ] Are phases ordered with clear per-phase "done" conditions?
- [ ] Does it know where every file (incl. moved ones) lives?
- [ ] Are test + verification steps runnable as written?
- [ ] Are secrets/PII handling and commit conventions explicit?
- [ ] Is "done" defined, with what to hand back to the user?
