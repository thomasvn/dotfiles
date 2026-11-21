---
name: update-claude-md
description: Add or change a rule in the user's system-wide ~/.claude/CLAUDE.md (also loaded by Codex as ~/.codex/AGENTS.md). Use when the user says "add this to my CLAUDE.md", "save this preference system-wide", "update my AGENTS.md", "remember this globally", or invokes /update-claude-md.
---

# Update CLAUDE.md

`~/.claude/CLAUDE.md` is loaded into every session, so each line costs context forever.

1. Read `~/.claude/CLAUDE.md`.
2. Find any existing rule the new preference overlaps or contradicts. Edit that line instead of appending a duplicate.
3. Write the rule as one terse bullet. Use a short example only if the wording is ambiguous without one.
   - Good: `- PR titles: under 8 words, no "fix:" style prefixes`
   - Bad: `- When creating pull requests, please make sure that titles are kept short...`
4. Place it next to related rules. Use a nested numbered list only when order is the point (e.g. priorities).
5. Show the user the before/after of changed lines.

The file is a symlink into the dotfiles repo. Don't commit unless the user asks.
