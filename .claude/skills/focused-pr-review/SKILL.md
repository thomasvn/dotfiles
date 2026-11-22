---
name: focused-pr-review
description: Review a GitHub PR for scope discipline — verify it does what it claims with the minimal set of changes, flag unrelated/excessive edits as revert candidates, and check the code is concise and maintainable. Use when the user says "review this PR", "focused review", "check PR for scope creep", "is this PR minimal", or invokes /focused-pr-review with a PR number.
---

# Focused PR Review

Goal: confirm a PR achieves its **stated purpose with the minimal set of changes**. Anything beyond that purpose is a revert candidate, even if individually harmless. Also judge whether the in-scope code is concise and maintainable.

## Inputs
- A PR number (and repo if the local `gh` default differs — this repo's `gh` may default to a fork; pass `--repo <owner>/<repo>` explicitly).

## Procedure

1. **Checkout + read intent.**
   - `gh pr view <N> --repo <owner>/<repo> --json title,body,author,additions,deletions,files,headRefName,baseRefName`
   - `gh pr checkout <N> --repo <owner>/<repo>`
   - Extract the *stated goal* from the PR body / linked issue (`Fixes #NNNN`). Every change gets judged against this goal.

2. **Get the true diff vs the base branch** (three-dot, from merge-base):
   - `git diff <baseRefName>...HEAD -- <each file>`
   - Do NOT trust the PR description's list of changes — read the actual hunks.

3. **Classify every hunk** into exactly one bucket:
   - **In-scope / keep** — directly implements the stated goal, plus its tests.
   - **Justified support** — not the headline change but required for correctness of it (e.g. a helper that fixes an edge case the fix would otherwise get wrong). Keep, but say *why* it's needed.
   - **Excessive / unrelated** — log-level tweaks, refactors, dependency swaps, reverts of prior work, comment churn, renames unrelated to the goal. These are **revert candidates.**

4. **Confirm each "excessive" claim against the base branch** before reporting it — avoid flagging something that's actually part of the intended change:
   - `git show <baseRefName>:<path> | grep -n "<old code>"` to prove the branch changed it.
   - Watch specifically for **regressions**: reverting a deliberate improvement (bounded timeouts, dedup logging, caching). Call these out as functional regressions, not just noise.

5. **Judge in-scope code quality** (concise, maintainable):
   - Duplicated blocks that could collapse into a small helper/closure.
   - Silent fallbacks that swallow errors.
   - Naming, guard clauses, over-verbose `var` decls.
   - Keep quality nits separate from scope findings, and mark them optional.

6. **Challenge the approach — is there a smarter/simpler fix?** Scope discipline asks "is every change needed?"; this step asks "is the change itself the *right* one?" Don't just validate the PR's chosen path — find the root cause and check the PR treats it, not a symptom.
   - **Trace to root cause.** Read the function(s) the bug flows through, not just the patched line. Follow the value that broke back to where it originated (e.g. a nil didn't come from the deref site — some upstream function returned it). State where the defect actually lives.
   - **Name the assumption the fix rests on**, then test it: "this belongs in each provider's `GetConfig`" — does it? "the panic is at the deref" — where does the bad value *enter*? "a guard here is enough" — what other callers hit the same path?
   - **Weigh alternative fixes** the PR didn't take, and say why the chosen one is better or worse:
     - *Root-cause vs symptom* — fixing the source (one place, all callers benefit) vs guarding each crash site (N places, easy to miss one).
     - *Local patch vs shared contract* — if the same latent bug exists in sibling code (other providers, other callers of the same helper), the local fix leaves landmines. Note them even if fixing all is out of scope for this PR — recommend a follow-up.
     - *Simpler construction* — could a `(value, ok)` return, an early guard, or an existing helper (`DefaultPricing()` vs a bare `&T{}`) express the same fix with less code or more correctness?
   - **Verdict:** either "chosen approach is the correct root-cause fix — no smarter path" (say so plainly, don't invent objections), or "a better fix exists: <what>, because <why>". Keep this separate from scope findings — it can *endorse* an in-scope change while suggesting a cleaner shape.

7. **Verify it works.**
   - Run the PR's new/changed tests: `go test ./<pkg>/ -run <TestName> -count=1` (adapt to language).
   - `go vet ./...` / `go fmt` check if touched (see repo AGENTS.md/CLAUDE.md).

8. **Double-check every recommendation for accuracy before reporting it — preferably with a fresh-context subagent.** Any claim you make (a change is "excessive", a refactor is "behavior-preserving", an alternative is "simpler/correct", a nit "collapses to X") is a recommendation that can be wrong. Verify each one against the actual code, not your mental model.
   - **Especially for suggested refactors / "collapse this" nits:** before asserting a rewrite is equivalent, read the body of *every* function it calls and check for non-obvious side effects, ordering, and lifecycle. A name like `Watch()`/`Init()`/`Load()` may do synchronous work (an initial fetch, a populate, a handler registration) — moving it (e.g. into a `defer`, a different branch, or a loop) can silently change behavior. State the concrete side effect you verified, not "should be fine".
   - **Prefer a subagent with fresh context** to audit your draft findings — it isn't anchored to the conclusion you already reached, so it catches equivalence claims and root-cause assertions you rationalized. Spawn it **only if the user asked for a subagent or approved one** (per the Agent-tool policy): give it the draft review + the diff and ask it to independently confirm or refute each finding against the code, reading called-function bodies. Otherwise self-audit: re-derive each claim from the source as if seeing it cold, and drop or downgrade any you can't prove.
   - If a check fails, **correct or delete the finding** — a wrong recommendation is worse than none. Downgrade "duplication, collapse it" to "leave as-is" when the branches encode a real semantic/lifecycle difference.

9. **Report** as a table: `Line | Change | Bucket | Reasoning`. Lead with the verdict (does it achieve the goal minimally?), then in-scope keeps, then excessive→revert, then optional nits. Include an **Approach** section for the step-6 verdict when there's a smarter/simpler fix or a systemic latent bug worth a follow-up.
   - **Always write the review to a markdown file** for human review (e.g. `pr-<N>-review.md` in the repo root), in addition to summarizing in chat. Do this by default — don't wait to be asked.

## Simplifying in-scope code (when the user wants minimal/simple logic)

Only touch code the PR already changed — don't expand scope. Aim for clear, minimal, simple architecture:

- **Extract a helper for any block written more than once.** One source of truth for a formula/lookup. (e.g. a `diskCost(key, size) (*float64, bool)` helper instead of the same parse-compute-return block in both the primary and fallback paths.)
- **Collapse `var x; var y; var z` soup + deep nesting** into short-lived `if`-scoped decls: `if v := f(); cond { ... }`.
- **Prefer `(value, ok)` returns** for best-effort lookups so the caller reads as a clean priority chain (try region-specific, else fall back).
- **Skip redundant work** with a cheap guard (e.g. `region != "" && region != ClusterRegion` before a duplicate lookup).
- **Merge error branches that differ only in debug wording**, but keep error messages that aid real debugging (missing key vs unparseable value).
- Don't over-abstract: a helper used once, indirection with no reuse, or a config knob nobody asked for is scope creep too.

After editing, always: `gofmt -l <file>` (adapt per language), `go vet ./<pkg>/`, and run the PR's tests (`-count=1`). Confirm reported diagnostics are pre-existing and not on your changed lines. Show the before/after and state what shrank and any behavior delta.

## Posting comments (only if the user asks)
Posting to a public PR is outward-facing and hard to undo — **confirm before posting**, and respect a "just show me in chat" answer.
- Draft a JSON review and submit one review with inline comments:
  ```
  gh api repos/<owner>/<repo>/pulls/<N>/reviews -X POST --input review.json
  ```
  `review.json`: `{ "commit_id": "<HEAD sha>", "event": "COMMENT", "body": "...", "comments": [ {"path","line","side":"RIGHT","body"} ] }`
- For each excessive change, the comment states what it is, why it's out of scope (or a regression), and asks: "can we revert this / move it to a separate PR?"
- Use `event: "COMMENT"` (not `REQUEST_CHANGES`) unless the user wants to formally block.

## Principles
- Minimal beats clever. A change that isn't needed for the stated goal is a cost, not a bonus.
- **Minimal-in-scope still has to be the right fix.** Challenge the approach, not just the line count: patch the root cause, not the symptom; flag the same latent bug in sibling code even when fixing it all is a separate PR. A correct root-cause fix earns an explicit endorsement — don't manufacture a "smarter" alternative when none exists.
- Unrelated ≠ wrong, but it belongs in its own PR. Say so.
- Always distinguish *unrelated-but-harmless* from *unrelated-and-a-regression*.
- Verify claims against the base branch before asserting them.
- **Every recommendation is a claim that can be wrong — double-check it before reporting (step 8).** Never assert a refactor is "behavior-preserving" without reading the bodies of the functions it calls; a wrong nit is worse than a missing one.
