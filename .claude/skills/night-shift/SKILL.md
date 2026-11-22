---
name: night-shift
description: Run an unattended overnight work loop on the current repo — pick human-approved tasks from TODO.md (bugs first), write tests first, get plan and diff approved by six review personas (plus Codex if installed), pass all checks, and commit each task on one stacked branch, then write a short report. Use when the user says "night shift", "run overnight", "work through the queue while I'm away", or invokes /night-shift. Not for interactive work.
---

# Night Shift

Human did the day shift (specs, decisions). You do the night shift: implement, verify, commit. Nobody is watching — never stop to ask. Burn tokens so the human never catches a basic issue.

**Invoking this skill is the user's explicit permission to run local git commands in this repo:** create/switch to the night branch, stash, add, commit. Never push, never rebase or rewrite existing commits, never touch other branches, never open PRs.

## 0. Prep
1. `git status`. If dirty: `git stash push -u -m "night-shift prep $(date +%F)"` and note it in the report.
2. Create the branch `night-shift/<YYYY-MM-DD>` from the current HEAD (reuse it if it exists). All commits stack here.
3. Read `CLAUDE.md` / `AGENTS.md` and the docs they route to. Find the project's verify commands (tests, lint, typecheck, build). If none exist, the first task is to note that in the report — still proceed, but treat each task's new tests as the only safety net.
4. Run the full verify suite. Fix failures before new work (each fix = its own commit).

## 1. Pick a task
Only take tasks the human marked as ready. Source: `TODO.md` unchecked items tagged `[night]`.
- Bugs first (`[night] bug: ...`), then features, in file order.
- A feature needs a spec: the linked file (e.g. `Specs/foo.md`, `SPEC.md` section), or enough detail in the item itself. Skip `draft-*` specs.
- Never take untagged items — they're not ready.
- If a task turns out to need a human decision, move it under `## Needs input` in `TODO.md` with the exact question, and pick the next one.

## 2. Per task
1. Load the spec, then the relevant docs, then the relevant code.
2. **Write a testing plan** (what proves this works, incl. edge and failure paths). This is the most important step.
3. Write the tests. Run them; confirm they fail for the right reason.
4. Write your own implementation plan (for you; the human won't read it).
5. **Plan review:** spawn the six personas in [personas.md](personas.md) as parallel subagents. Give each the spec, testing plan, and plan. Each returns `APPROVE` or a short list of required changes (plus any doc update it wants). Adapt the plan and re-review until all approve, **max 3 rounds** — unresolved objections go in the report.
6. Implement, including doc updates (keep CLAUDE.md/SPEC.md/docs in sync with behavior).
7. Run static checks at their strictest (lint, format, typecheck, build) plus the task's tests. Fix everything.
8. Run the full test suite. Fix regressions.
9. **Diff review:** personas again on `git diff` (max 3 rounds). If `codex` is on PATH, also run `codex review --uncommitted` and treat its findings like a seventh reviewer. Loop to step 7 after any change.
10. Unrelated issues you noticed: add to `TODO.md` under `## Found overnight` (untagged — human triages). Don't fix them.
11. Add a `CHANGELOG.md` entry (create the file if missing, newest on top).
12. Check off the `TODO.md` item. Commit with a detailed message written for the human reviewer: why, what changed, how it was verified, anything uncertain. No AI attribution lines.

Then go back to step 1.

## 3. Done
When no `[night]` tasks remain (or everything left is blocked), write the report to `~/.claude/night-shift/<repo>-<YYYY-MM-DD>.md`:

```markdown
# Night shift — <repo> — <date>
Branch: night-shift/<date> (N commits, not pushed)  ·  Stash: <none | name>

| Commit | Task | Verified by | Watch out for |
|---|---|---|---|
| abc1234 | bug: … | 3 new tests, full suite green, codex clean | … |

Needs input: <questions moved to TODO.md>
Unresolved reviewer objections: <…>
Gaps that slowed me down: <missing docs, tests, tooling — fixes the human should consider>
```

Keep it short; details live in commit messages. Print the report path as your final line, then stop.
