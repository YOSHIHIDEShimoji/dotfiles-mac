# Service & CLI capability checks

Before writing the plan, verify each chosen service is actually usable from the
CLI. Run the check, read the result, and if it fails, prompt the user to fix it
and wait. Record the verified status in the plan's "services" table.

Principle: **don't just check `--version`. Check auth, and check the specific
capability the project needs** (usually "can create a project/resource").

## Native access first (use the service's OWN CLI/API/token — never a proxy)

This is the most important rule and applies to **every** service, not just the
common ones below.

1. For each service, **first check whether it is already authenticated via that
   service's own native CLI / API / token** (`neonctl me`, `vercel whoami`,
   `gh auth status`, `supabase projects list`, `wrangler whoami`, `fly auth whoami`,
   `aws sts get-caller-identity`, a `<SERVICE>_API_KEY`/token in env or a known
   config…). If it's authenticated, **use that native access** to create and
   manage everything.
2. **Never provision or manage a service through another service's
   integration / marketplace / proxy** when native access exists. Concretely:
   do **not** create a Neon DB with `vercel integration add neon`, a database
   "via Vercel", etc. Proxy-provisioned resources are **owned by the proxy**
   (e.g. a Vercel-managed Neon org), do **not** appear in the user's own account,
   and **cannot be managed with the native CLI** — a worse, hard-to-undo setup
   (you end up migrating it back later, as happened once).
3. For a **new/unfamiliar service**, apply the same order: look for its native
   CLI or an already-issued API key/token and verify auth before anything else.
   Only if there is genuinely no native access AND the user agrees, fall back to
   a proxy/marketplace.
4. Record in the plan/CLAUDE.md **how each service authenticates** (which native
   CLI/token), so future sessions reuse the same direct path.

## Common services

### Vercel (hosting)
- Installed + auth: `vercel whoami` (the CLI's own login — use it directly).
- Scope/teams: `vercel teams ls` ; existing projects: `vercel projects ls`
- Create capability: `vercel project add <tmp>` then `vercel project rm <tmp>`
  (clean up the probe). Confirms create rights without leaving junk.
- Per-env var gotcha: `vercel env rm <NAME> <env>` can drop the var from **all**
  environments (one merged entry). To set different values per env, **remove then
  add each of production/preview/development explicitly**, and verify with
  `vercel env ls`. Keep a backup of the production value before touching it.

### Neon (Postgres) — always via `neonctl`, never via Vercel
- Installed + auth: `neonctl me`. If logged in, **provision Neon directly with
  `neonctl`** — do NOT use `vercel integration add neon` (that creates a
  Vercel-managed Neon org the user can't see in their own Neon account).
- Pick the **user's personal org** so the project shows in their Neon dashboard.
  List orgs (the `projects list` org prompt shows them); a "Vercel: …" org is the
  proxy one — avoid it, use the personal org id.
- Existing: `neonctl projects list --org-id <personal-org>`
- Create capability: `neonctl projects create --name <probe> --org-id <personal-org>` →
  connection URI works → `neonctl projects delete <id> --org-id <personal-org>`.
  (A "Projects Limit: 0" in `neonctl me` can be a display quirk — the real test
  is an actual create.)
- Two-env pattern: **one project, branches `main`(prod) + `develop`(dev)**
  (`neonctl branches create --project-id <id> --name develop`). Use pooled URIs
  (`neonctl connection-string <branch> --project-id <id> --pooled`). Wire each
  Vercel env's `DATABASE_URL` manually to the matching branch.

### GitHub
- `gh auth status` ; repo: `gh repo view --json nameWithOwner,visibility`
- Visibility: if it handles private/PII data, recommend `gh repo edit --visibility private`.

### Supabase (DB/auth/storage alt)
- `supabase projects list` (keychain auth on macOS).

### Postgres client (schema/SQL)
- `psql --version` (may live at a non-PATH location, e.g. libpq under Homebrew).

### Others (check analogously)
- Cloudflare (`wrangler whoami`), Fly (`fly auth whoami`), Railway, Render,
  AWS (`aws sts get-caller-identity`), etc. Always: installed → authed →
  can-create.

## When a check fails — prompt setup (then wait)
Tell the user the exact remedy, e.g.:
- Not installed: "`brew install <cli>` してください"
- Not authed: "`vercel login` / `neonctl auth` してください"
- No remote/repo: "GitHub リポジトリを用意してください（`gh repo create`）"
- Missing key: "`<SERVICE>` の API キーを発行して `.env.local` に置いてください"

Re-run the check after they confirm. Only write the plan once every required
service is green.

## Probe hygiene
- Always delete probe projects/resources you create for capability tests.
- Never commit secrets or connection strings printed by these commands.
