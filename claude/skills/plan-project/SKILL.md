---
name: plan-project
description: >-
  Turn a project idea or existing requirements into ONE self-driving plan file
  (docs/plan.md) plus a root CLAUDE.md, so a fresh Claude Code session can build
  the whole project autonomously without the user babysitting. Use when the user
  runs /plan-project, says "plan this project", "プロジェクトのプランを立てて",
  "要件からプランを作って", "kick off a project", or wants a hand-off plan another
  session implements from. This skill writes ONLY docs/plan.md and CLAUDE.md (and
  relocates stray files) — it NEVER writes application code. It confirms branch
  strategy, services (hosting/DB/etc.), design source, verifies the required CLIs
  actually work, prompts the user to finish any setup BEFORE writing the plan,
  suggests helpful skills/plugins, and ends with a hand-off instruction.
---

# Plan Project

Produce a plan so complete that a brand-new Claude Code session, reading only
`docs/plan.md`, can implement the project end-to-end and deploy it — with the
user doing nothing but the final review. Consistency is the point: every run
yields the same high quality.

## Hard rules

- **Write no application code.** Only create/edit `docs/plan.md`, the root
  `CLAUDE.md`, and (when asked) move stray files. If tempted to scaffold or code,
  stop — that belongs to the implementation session.
- **Verify, don't assume.** Actually run the CLI checks (`vercel whoami`, etc.).
  Never claim a service is usable without checking.
- **Block on real setup gaps.** If a required CLI is missing/unauthed, prompt the
  user to fix it and wait. Do not write the plan around a broken prerequisite.
- **Ask before guessing.** Use `AskUserQuestion` for decisions that change the
  build. Don't overwhelm — batch the few that matter, recommend a default.
- **The plan must stand alone.** Assume the implementing session has zero memory
  of this conversation. Spell out paths, commands, and decisions.

## Workflow

Run these in order. Each later step may send you back to ask more.

### 1. Find the starting point & assess repo state
- Look for an existing requirements doc (`docs/要件定義.md`, `docs/requirements*.md`,
  `doc/requirements.md` — the output of the `design-strategy` skill —, a README
  spec, etc.). If found, read it and build on it.
- If none, gather the idea through dialogue: what it is, who uses it, core flows,
  must-haves vs out-of-scope. Capture enough to design from.
- **Assess the repo**: greenfield vs existing codebase, is it a git repo, is there
  a remote, current framework/stack if any. Adapt the plan to what's already there
  (don't plan a scaffold over an existing app).

### 2. Interrogate until a self-driving plan is possible
- Hunt for ambiguity and resolve it now (data-model edge cases, rules,
  validation, privacy constraints, failure/empty states).
- Be a strict reviewer: if the spec has a hole the implementer would trip on,
  surface options + a recommendation via `AskUserQuestion`.

### 3. Branch & environment strategy
- Default: **`main` (production) + `develop` (dev)**, two fixed URLs, push only
  those two branches, `develop` for work, `main` merge needs the user's explicit
  go. Ask: **"main + dev のこの運用でいい？"** and adjust to their answer.
- Record the exact URL / DB-branch mapping in the plan and CLAUDE.md.

### 4. Design source
- Ask how the UI/design is decided. Check for an existing design spec file
  (`DESIGN-*.md`, a generated design system, brand assets).
- If none, propose options (e.g., use `ui-ux-pro-max`, generate a design system,
  or a named style) and let the user pick. Record the chosen direction + file.

### 5. Services & CLI capability check
- Confirm the services the project needs (hosting, DB, auth, mail, analytics…).
  For a typical web app that's often **Vercel (host) + Neon (Postgres)**, but
  this skill is general — confirm each.
- **Native access first.** For every service (common or brand-new), first check
  whether it's already authenticated via **that service's own native CLI / API /
  token**, and if so use that to create/manage. **Never provision a service
  through another service's marketplace/proxy** (e.g. Neon via
  `vercel integration add neon`) when native access exists — proxy-owned
  resources don't show in the user's own account and can't be managed natively.
- For every chosen service, **verify its native CLI/token is installed,
  authenticated, and can do what the project needs** (e.g., create a project).
  See [references/service-checks.md](references/service-checks.md).

### 6. Prompt setup BEFORE writing the plan
- If any check fails (CLI missing, not logged in, no project quota), tell the user
  exactly what to do and **wait**. Re-check after they confirm. Proceed only when
  every prerequisite is green.

### 7. Suggest helpful skills & plugins
- Scan available skills and recommend the ones that fit (for web UI, almost
  always offer **`ui-ux-pro-max`**). Suggest relevant plugins too.
- Ask which to adopt; record the chosen ones in the plan (e.g., "use ui-ux-pro-max
  in the UI phases").

### 8. Relocate stray files
- Find files the user dropped ad-hoc (loose data files, design specs, sample
  inputs) and move them to natural locations (sample/seed data → `data/` or a seed
  dir, design spec → `docs/`, fixtures → a test dir). Add sensitive data files to
  `.gitignore`.
- Reflect the new paths in the plan so the implementer finds them.

### 9. Propose the screen composition (IA & navigation)
- Once the design is settled, propose a concrete screen/UI structure derived from
  the requirements: the list of screens, the navigation/tab structure, and roughly
  what each screen holds and how the user moves between them.
- Present it as a recommendation ("設計を踏まえると、こういう画面構成・タブ構成が
  いいのでは？") via `AskUserQuestion` or a short outline, and refine with the user.
- Record the agreed screens + navigation in the plan's 画面構成 section — detailed
  enough that the implementer builds the same information architecture.

### 10. Write the outputs (no code)
- Write **`docs/plan.md`** using
  [references/plan-template.md](references/plan-template.md). It must cover:
  context, scope, **不変条件 (must-not-break)**, services + verified CLI status,
  branch/env strategy, design direction, **screen composition (IA/navigation)**,
  data model/architecture, **API/endpoints**, **環境変数 table**, phased
  implementation, file locations (incl. relocated files), **seed data +
  happy-path E2E**, test methods, verification & deploy checks, prerequisites,
  **中断ポイント (where to stop for the user)**, **risks & mitigations**,
  conventions/secrets, **Decision Log (with rationale)**, and the "done" definition.
- While planning, actively note **中断ポイント**: anything the implementer can't do
  alone (DNS, paid upgrades, user-only secrets). List them so the build pauses
  only there — that is how the user avoids babysitting.
- Write/refresh the root **`CLAUDE.md`** using
  [references/claude-md-template.md](references/claude-md-template.md).
- If a separate requirements doc exists, link it from `plan.md` rather than
  duplicating it.

### 11. Explain it to the user in plain language
- After the plan is written, describe — without code-speak — **what app you'll
  build and what the user will be able to do** ("Users can register, see X, do
  Y…"). Then a short plain list of services ("Vercel でビルド・公開、Neon でDB管理").
  Keep it human.

### 12. Hand off to an implementation session
- Tell the user to open a **new session** and use the built-in **`/goal`**
  command (Claude Code v2.1.139+): set a completion condition, then give the
  kickoff instruction, e.g.:

  > 新しいセッションを開いて、次を実行してください:
  > `/goal docs/plan.md の全フェーズが実装され、検証手順がパスし、デプロイまで完了している`
  > 続けて: `docs/plan.md を読んで、このプロジェクトを実装し、デプロイまで完成させて`

- Derive the `/goal` condition from the plan's "done" definition — **measurable
  end states** (tests pass, deploy URL live) work better than vague ones.
- Adjust the wording to the project, but the intent is fixed: **read the plan →
  implement → verify/deploy to completion.**

## Quality bar

Before finishing, confirm the plan passes the self-driving checklist in
[references/plan-template.md](references/plan-template.md): a fresh session with
only `docs/plan.md` could build, test, and ship this with no further questions.
