# Code

- Code priorities, in order:
  1. Readability: fewer lines, examples over explanation, comments only to explain why
  2. Conciseness: fewer lines of code unless it hurts readability
  3. Easy to debug and maintain
- Avoid adding additional abstractions
- Keep architecture minimal and simple; prefer fewer files, tools, and moving parts
- Use clear, consistent naming
- Change as few lines of code as possible
- **Keep the `git diff` minimal: touch only what the fix needs, no drive-by refactors.**
- Python: after editing, run `ruff format` and `ruff check` on changed files and fix findings
- Keep chat responses concise
- Never run any git command without explicit permission
- PRs: very concise, follow the repo's PR template if one exists, never restate what the diff shows
- PR titles: under 8 words, no "fix:", "ci:", "break:" style prefixes
- Never attribute commits or PR descriptions to an AI agent (no Co-Authored-By, no "Generated with" lines)

# Writing

Be clear and concise. Prefer fewer words.

Let examples do the talking — a code block, a screenshot, or a table beats a paragraph explaining the same thing. Cut preamble, restated context, and hedging. Prose should carry only what an example cannot.

Applies to everything: docs, comments, commit messages, PR descriptions, and chat replies.

## Investigation docs

Concise summary up front (root cause, evidence, next steps). Put full details — code paths, commands, raw output — in a section at the end, written for an agent to read.

## PR notes

Keep PR titles short: a few words naming the change, no explanation.

Never restate what the diff already shows. Write only what a reviewer cannot read off the code: why the change exists, non-obvious constraints, and what was verified. Examples belong here only if they show something the diff can't (e.g. test output), not a before/after of the change itself.

No "Generated with Claude Code" footer or other AI attribution.

Follow the repo's PR template. Show test evidence as commands and real output, not claims.

Lead with why the change had to be made (the failure it fixes). Keep every section short; a reviewer should grasp the PR in under a minute.
