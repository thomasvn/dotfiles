---
name: claude-md
description: Maintain an always-loaded memory file (CLAUDE.md / AGENTS.md) — add or change a rule in the user's system-wide ~/.claude/CLAUDE.md, or slim down a bloated one by cutting generic filler, lint-duplicating rules, and task-specific cruft and pushing detail out to referenced docs (progressive disclosure). Use when the user says "add this to my CLAUDE.md", "save this preference system-wide", "update my AGENTS.md", "remember this globally", "slim down CLAUDE.md", "trim my AGENTS.md", "my memory file is too long", "reduce context bloat", or invokes /claude-md. Preserves hard-won project facts; deletes only true noise.
---

# CLAUDE.md

A memory file (`CLAUDE.md` / `AGENTS.md`) is injected into every prompt, so each line costs context
forever. Its contents compete for a limited instruction budget — frontier models degrade as input grows,
and only ~150–200 instructions get followed reliably (Claude Code's own prompt already spends ~50).
Shorter measurably helps; it is not just tidiness.

`~/.claude/CLAUDE.md` is a symlink into the dotfiles repo, also loaded as `~/.codex/AGENTS.md`,
`~/.kiro/steering/AGENTS.md`, and `~/.config/amp/AGENTS.md`. Don't commit unless the user asks.

Pick the mode from the request: **Add a rule** or **Slim a file**.

## Add a rule

Default target: `~/.claude/CLAUDE.md`.

1. Read the file.
2. Find any existing rule the new preference overlaps or contradicts. Edit that line instead of appending a duplicate.
3. Write the rule as one terse bullet. Use a short example only if the wording is ambiguous without one.
   - Good: `- PR titles: under 8 words, no "fix:" style prefixes`
   - Bad: `- When creating pull requests, please make sure that titles are kept short...`
4. Place it next to related rules. Use a nested numbered list only when order is the point (e.g. priorities).
5. Show the user the before/after of changed lines.

## Slim a file

The danger: a naive pass deletes real learnings (a hard-won `kind`+`podman` gotcha, a dated design
decision) as if they were filler. **Default to relocating detail, not deleting it.** Cut only true noise.

### Inputs
- A file path. Default to `CLAUDE.md`, then `AGENTS.md`, in the repo root if none given.
- If the user names a line-count target, use it. Otherwise aim for **≤ ~200 lines / one–two screens**.

### Procedure

1. **Read the file. Count lines** (`wc -l`). Note where it sits vs the target. Report the starting number.

2. **Classify every block** into exactly one bucket:
   - **KEEP inline** — universally-applicable, load-every-session facts: what the project is, why parts
     exist, how to build/test/run, non-obvious project-specific rules and decisions. This is the core.
   - **CUT** — pure noise, delete outright:
     - *Generic filler* — "write clean code", "use best practices", "be careful". Models already do this.
     - *Lint/format-duplicating rules* — style prose a formatter/linter enforces deterministically.
       (If the user cares, the fix is a Stop hook running the formatter, not prose — mention this.)
     - *Task-specific cruft* — instructions that only matter for one occasional task (e.g. "how to add
       a new DB schema"). Belongs in a prompt or a doc, not the always-loaded file.
     - *Stale / superseded* — contradicted by a later decision or by the current code.
   - **RELOCATE (progressive disclosure)** — valuable but not needed every session. Move the body to a
     referenced doc (`docs/…`, `agent_docs/…`) and leave a one-line pointer. This is the main lever for
     long files: pasted code, long command transcripts, deep-dive research, background/"prior art".
     Tell it *how to find* the info, don't inline it.
   - **DEMOTE to HTML comment** — human-only "why" notes with no bearing on model behavior. Block-level
     `<!-- … -->` comments are stripped before the file hits context → **zero tokens**, but stay visible
     to maintainers. Good home for rationale you want to keep for people.

3. **Apply the cuts.** Rewrite the file:
   - Merge duplicated/overlapping sections; collapse verbose prose to imperative bullets.
   - Preserve exact technical tokens verbatim — commands, flags, paths, error strings, code fences,
     URLs, dated `Decision (YYYY-MM-DD)` markers. Never paraphrase a command or an error.
   - When relocating, actually create the target doc (move the content there), then leave the pointer.
     Don't drop content on the floor claiming a doc exists that doesn't.

4. **Safety.** These files are usually git-tracked — the diff is the backup. If the target is **not**
   tracked (`git ls-files --error-unmatch <file>` fails), write a `<file>.original.md` backup first.

5. **Report a changelog.** After rewriting, show:
   - Line count **before → after**.
   - Per bucket, a short list of what was CUT / RELOCATED (→ where) / DEMOTED, each with a one-line reason.
   - Never silently drop a hard-won fact — if unsure whether something is noise, KEEP it and flag it for
     the user to decide rather than delete it.

### Guardrails
- **Relocation ≠ deletion.** Moving detail to a doc keeps it; deleting it loses it. When torn, relocate.
- **This file may be a journal of real learnings** (gotchas hit-and-fixed, inverted-on-purpose decisions).
  Those are the highest-value content, not filler — protect them. Terseness ≠ throwing them away.
- **Don't invent structure.** Keep the file's existing headings/voice unless merging genuinely helps.
- **Simplicity check last** — a slimmed file that still repeats itself isn't done. Re-read before finishing.
