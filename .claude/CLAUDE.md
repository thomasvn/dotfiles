# Code

- Code priorities, in order:
  1. Readability: makes sense on first read; fewer lines, examples over explanation, comments only to explain why (workarounds, non-obvious constraints)
  2. Conciseness: fewer lines of code unless it hurts readability; no clever one-liners that need decoding
  3. Easy to debug and maintain: fail loudly with errors that say what went wrong and where to look; log key decisions (e.g. resolved inputs); make tracing easy to turn on
- Minimal architecture: no extra abstractions; prefer fewer files, tools, and moving parts; don't create a function, helper, or variable used only once — inline it and comment if the intent needs explaining
- Use clear, consistent naming
- Change as few lines of code as possible
- **Keep the `git diff` minimal: touch only what the fix needs, no drive-by refactors.**
- Python: after editing, run `ruff format` and `ruff check` on changed files and fix findings
- Keep chat responses concise
- Never run any git command without explicit permission
- Never attribute commits or PR descriptions to an AI agent (no Co-Authored-By, no "Generated with" lines)
- PRs:
  - Title: plain language, under 8 words, no "fix:", "ci:", "break:", "chore:", "feat:" style prefixes
  - Body very concise; follow the repo's PR template if one exists; never restate what the diff shows
  - When possible, show test evidence (before/after output), with enough tests that the result is irrefutable
- Never comment, reply, or review on GitHub on my behalf; draft the text in chat for me to post
- Temporary `*.test.sh` files are fine for local validation; delete them and any references before finishing, never commit them

# Writing

Be clear and concise. Prefer fewer words.

Let examples do the talking — a code block, a screenshot, or a table beats a paragraph explaining the same thing. Cut preamble, restated context, and hedging. Prose should carry only what an example cannot.

Applies to everything: docs, comments, commit messages, PR descriptions, and chat replies.

## Investigation docs

Concise summary up front (root cause, evidence, next steps). Put full details — code paths, commands, raw output — in a section at the end, written for an agent to read.

## PR notes

Keep PR titles short: a few words naming the change, no explanation.

Never restate what the diff already shows. Write only what a reviewer cannot read off the code: why the change exists, non-obvious constraints, and what was verified. Examples belong here only if they show something the diff can't (e.g. test output), not a before/after of the code itself.

When a change alters user-visible output (a message, report, log, UI), show a simple, clean BEFORE / AFTER of that output so readers grasp the change at a glance.

No "Generated with Claude Code" footer or other AI attribution.

Follow the repo's PR template. Show test evidence as commands and real output, not claims.

Lead with why the change had to be made (the failure it fixes). Keep every section short; a reviewer should grasp the PR in under a minute.

Default to very short PR notes: a 1–2 sentence Why and a 1–2 line Verification, about 60 words total. Skip feature walkthroughs, overlap tables, and raw command output unless a reviewer needs them to judge the change.

## PR reviews

Every review checks two things: bugs, and opportunities to simplify (per the Code priorities above). Report both, or say plainly that none were found.

Review the PR head, not just local files. Prove each bug by running it (e.g. a failure-path test with a fake dependency), not by reading alone. Skip nitpicks.

Draft the review in chat; never post it on GitHub.
