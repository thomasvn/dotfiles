# Code

- Code priorities, in order:
  1. Readability: makes sense on first read; fewer lines, examples over explanation, comments only to explain why (workarounds, non-obvious constraints)
  2. Conciseness: fewer lines of code unless it hurts readability; no clever one-liners that need decoding
  3. Easy to debug and maintain: fail loudly with errors that say what went wrong and where to look; log key decisions (e.g. resolved inputs); make tracing easy to turn on
- Errors, in order: 1) return them up wrapped with context (`fmt.Errorf("...: %w", err)`); 2) log only where they can't be returned, never in a spammy way (e.g. not once per item or retry); 3) follow the codebase's message format, e.g. a `pkg:` prefix naming where it came from (`log.Errorf("configstore: importing %s: %s", path, err)`)
- Minimal architecture: no extra abstractions; prefer fewer files, tools, and moving parts; don't create a function, helper, or variable used only once — inline it and comment if the intent needs explaining
- Use clear, consistent naming
- **Change as few lines as possible; keep the `git diff` minimal: touch only what the fix needs, no drive-by refactors.**
- Tests: add to the existing test file for the source file under test (e.g. Go `foo.go` → `foo_test.go`); create a new test file only when none exists, never one per feature or PR
- Python: after editing, run `ruff format` and `ruff check` on changed files and fix findings
- Temporary `*.test.sh` files are fine for local validation; delete them and any references before finishing, never commit them
- Never run any git command without explicit permission
- Always squash-merge branches into main (one commit per branch/PR); never a regular or rebase merge
- Never attribute commits or PRs to an AI agent (no Co-Authored-By, no "Generated with" lines or footers)
- Never comment, reply, review, or post on GitHub on my behalf; draft the text in chat for me to post

# Writing

Be clear and concise. Prefer fewer words. Applies to everything: docs, comments, commit messages, PR descriptions, and chat replies.

Let examples do the talking — a code block, a screenshot, or a table beats a paragraph explaining the same thing. Cut preamble, restated context, and hedging. Prose should carry only what an example cannot.

When referencing another PR, always use its full GitHub link, e.g. `[kubecost-cost-model#5242](https://github.com/kubecost/kubecost-cost-model/pull/5242)`, never a bare `kubecost-cost-model#5242` or `#5242`.

## Investigation docs

Concise summary up front (root cause, evidence, next steps). Put full details — code paths, commands, raw output — in a section at the end, written for an agent to read.

## PR notes

- Title: plain language, under 8 words, naming the change; no "fix:", "ci:", "break:", "chore:", "feat:" style prefixes
- Open PRs as drafts. Follow the repo's PR template; if none, use `## Why` and `## Testing`.
- Agents don't write the PR body; I do, so I understand the change. Every section except Testing is `TODO` for me, followed by a hidden `<!-- -->` comment holding what the agent would have written. Later body edits touch only those comments and Testing, and start from the live body (`gh pr view --json body`), never a local copy, so my edits survive. Example:
  ```md
  ## Why
  TODO
  <!-- Skills lived only in ~/.claude/skills; Kiro had a stale copy missing 4. -->
  ```
- The rules below apply to the hidden comments and Testing.
- Comment draft skimmable in seconds, leading with why the change had to be made:
  1. One sentence stating the problem.
  2. One sentence giving an example of the problem.
  3. A short description of the solution.
- Never restate what the diff shows (no before/after of the code). Write only what a reviewer cannot read off it: why, non-obvious constraints, what was verified.
- When a change alters user-visible output (a message, report, log, UI), show a simple, clean BEFORE / AFTER of that output.
- Anything beyond those three points (stats, edge-case reasoning, why a risk is fine) goes in a collapsed `<details>` block, never visible prose. Skip feature walkthroughs, overlap tables, and raw command output unless a reviewer needs them.
- **Test evidence MUST be IRREFUTABLE**: a skeptical reviewer cannot doubt the change works. Real commands and output, never claims; run the real paths it touches end to end; show the BEFORE failing and the AFTER passing on the same check.
- Show only the fewest tests that prove the change works; skip what CI catches or what is obvious (syntax checks, file exists).
- Make each test plain and skimmable, with an obvious BEFORE / AFTER. No summary table or prose recapping tests. Each test is its own `<details>` whose `<summary>` is the result in under 8 words, e.g. `<summary>updateCaTrust: Init:Error → Running</summary>`, with setup, commands and output inside.

## PR reviews

Every review checks two things: bugs, and opportunities to simplify (per the Code priorities above). Report both, or say plainly that none were found.

Review the PR head, not just local files. Prove each bug by running it (e.g. a failure-path test with a fake dependency), not by reading alone. Skip nitpicks.

Call out edge cases, but label how likely each is: say plainly when one needs unusual, non-default config or rare conditions that users are unlikely to hit, and keep it separate from bugs that hit the default path.

# Skills

Create and update skills only in `~/code/dotfiles/.claude/skills/<name>/`, never in `~/.claude/skills/` or `~/.kiro/crew/skills/`. `sync.sh` links them for Claude Code and Kiro CLI, and KiroCrew reads the repo folder via `skills.extra_paths`.
