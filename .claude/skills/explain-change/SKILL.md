---
name: explain-change
description: Explain a file, package, or PR so the user understands it fast - a high-level overview first, then the details that matter (behavior changes, surprises, risks, open questions), each checked against the code or a real run. Use when the user says "help me understand X", "explain this file/package/PR", "walk me through", "what changed in", "give me an overview of", or invokes /explain-change with a path, package, or PR.
---

# explain-change

Goal: the user knows what the target does and what changed, and can trust every claim.

## Inputs

- **File path**: explain the file. If the branch changed it, explain the change.
- **Package or directory**: explain its role and the branch's changes across it.
- **PR** (URL or number): explain the diff against its base.
- **Focus** (optional, e.g. "just the sharding"): narrow steps 2-6 to it.

Invoking this skill allows read-only `git` and `gh` commands (`log`, `diff`, `show`, `gh pr view`,
`gh pr diff`). Ask before anything that changes state (`fetch`, `checkout`, `commit`).

## Steps

1. **Pick the baseline.** Explain everything relative to something, and say what:
   - PR or branch: its merge-base with the base branch, or `gh pr diff N`.
   - Modified file: its version at that merge-base.
   - New file: the closest existing code it ports, replaces, or copies. Find it from header
     comments, commit messages, and `grep` for the names it defines.

2. **Get the shape before reading line by line.** Over ~300 lines, inventory with a script:
   sections and the things defined (tables, functions, types, routes), grouped by family with
   counts. Example: 100 tables = 6 bookkeeping + 30 fact families x {1d,1h,10m} + 4 broadcast.

3. **Read the intent.** Header comments, TODOs, `git log --format='%h %s' <base>..HEAD -- <path>`,
   the PR body, ticket keys. Note what the author says is deliberately missing.

4. **Diff at the level that matters, with the real mechanism.** Run the real thing over parsing text:
   - SQL schema: apply baseline and new migrations to a real database, then diff
     `system.columns` and `system.tables` (types, sort keys, partitioning, engines).
   - Code: diff exported API and signatures; `grep` every caller of what changed.
   - Config or CLI: run both versions and diff the output.

   Group changes by family, not item by item.

5. **Check the neighbors.** Who reads or writes what the target defines, and what else defines
   the same names? Example: two migrations creating one table with `IF NOT EXISTS` means the
   second silently does nothing.

6. **Verify every important claim** against the code or a real run (a temporary test or scratch
   script, deleted after). Label anything unverified and say why.

7. **Report in chat.** Write a markdown file only if asked.
   - **Overview** (5 sentences max): what it is, why it exists, where it fits, what you compared it to.
   - **Shape**: one table from step 2.
   - **Important details**, most important first: behavior changes, surprises, risks, gaps. Each
     gets what, where (`file:line`), evidence, and how likely it is to matter (default path vs.
     rare config).
   - **Open questions** for the author, worded so the user can paste them.

## Rules

- Lead with what the diff doesn't show: why, consequences, interactions. Don't restate code.
- Give real sizes: "47 of 110 duplicated tables differ", not "many tables differ".
- Don't edit the target, post on GitHub, or start fixes. Offer them.
