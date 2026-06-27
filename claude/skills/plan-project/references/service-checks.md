# Service & CLI capability checks

Before writing the plan, verify each chosen service is actually usable from the
CLI. Run the check, read the result, and if it fails, prompt the user to fix it
and wait. Record the verified status in the plan's "services" table.

Principle: **don't just check `--version`. Check auth, and check the specific
capability the project needs** (usually "can create a project/resource").

## Common services

### Vercel (hosting)
- Installed + auth: `vercel whoami`
- Scope/teams: `vercel teams ls` ; existing projects: `vercel projects ls`
- Create capability: `vercel project add <tmp>` then `vercel project rm <tmp>`
  (clean up the probe). Confirms create rights without leaving junk.

### Neon (Postgres)
- Installed + auth: `neonctl me`
- Existing: `neonctl projects list --org-id <org>`
- Create capability: `neonctl projects create --name <probe> --org-id <org>` →
  note the connection URI works → `neonctl projects delete <id> --org-id <org>`.
  (A "Projects Limit: 0" in `neonctl me` can be a display quirk — the real test
  is an actual create.)
- Two-env pattern: one project, branches `production` + `develop`.

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
