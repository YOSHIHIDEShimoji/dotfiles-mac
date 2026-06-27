# CLAUDE.md template — root operational rules

Write this to the repository root as `CLAUDE.md` (root, so Claude Code auto-loads
it every session). Keep it short and operational — it is the "house rules" the
implementing session and all future sessions rely on. Do NOT duplicate the full
plan here; link to `docs/plan.md` for detail.

Fill the placeholders and delete anything that doesn't apply.

```markdown
# <Project> — 運用ルール（毎セッション自動読み込み）

詳細プランは [docs/plan.md](docs/plan.md)。要件は [docs/要件定義.md](docs/要件定義.md)（あれば）。

## ブランチ運用
- リモートに push するのは **`main`** と **`develop`** の2本だけ。
- 通常作業は `develop` に直接コミット → 固定 dev URL で確認。
- `main` へのマージは **オーナーが「merge」と言ってから**。`main` 直 push 禁止。
- （任意）複数並行時のみ worktree。feature ブランチは push しない。

## 環境・URL・DB
| ブランチ | 環境 | URL | DB |
|---|---|---|---|
| main | Production | https://<app>.vercel.app | <prod DB / branch> |
| develop | Preview(固定) | https://<app>-dev.vercel.app | <dev DB / branch> |
- 固定dev URLは `develop` 追従。プレビュー保護の状態を明記。

## 使うサービスと鍵の置き場所
- <Vercel / Neon / 他>：役割を1行ずつ。
- シークレットは `.env.local`（ローカル）と <ホスティング> の環境変数のみ。**値は repo に書かない**。
- 主な鍵: `<NAME>` … 用途 / 置き場所（値は書かない）。

## マスタ/データ管理
- <研究室・名簿などマスタ> の編集方法（DB直編集 or seedスクリプト）。
- 機密データファイル（例: data/*.txt）は gitignore 済み。コミット禁止。

## コミット規約
- ユーザーのグローバル方針に従う（例: コミットに **Claude Code 署名を含めない**）。
- メッセージ言語・粒度の慣習があれば記載。

## 開発・テストコマンド
- 起動: `<npm run dev / vercel dev>`
- Lint/型: `<npm run lint / tsc --noEmit>`
- テスト: `<コマンド>`
- デプロイ: `<vercel deploy / push to main>`
```

## Notes
- The user's global `~/.claude/CLAUDE.md` may already set personal conventions
  (e.g., no Claude attribution in commits, trash instead of rm). Don't restate
  everything — reference "follow global rules" and add only project specifics.
- CLAUDE.md lives at the repo ROOT even though this skill otherwise writes under
  `docs/`. This is the one intended exception.
