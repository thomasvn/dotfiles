---
name: noisy-log-triage
description: Use when the user reports a log line (or error message) that repeats too often / floods logs, and wants to find its source and reduce the noise. Triggers on phrases like "noisy log", "repeated log line", "keep seeing this log", "spamming the logs", "flooding logs", or when pasting a log line and asking where it comes from and how to quiet it down.
---

# Noisy Log Triage

A repeatable process for turning "I keep seeing this bad log line" into: where it comes from, why it repeats, and a fix — without guessing.

## When to use this

The user pastes a log line (or a distinctive fragment of one) and wants to:
- find where it's emitted in the code, and/or
- understand why it fires so often, and/or
- reduce the noise (systemic fix, dedupe, or log-level change).

This applies across any language/log framework. It especially matters in codebases where the **log statement** and the **actual error source** live in different files, packages, or even different repos (e.g. a library logs a generic wrapper error, but the concrete error was constructed several layers down in a caller-supplied implementation).

## Process

### 1. Locate the log line

Grep for the literal, most distinctive substring of the message (skip interpolated values like numbers/IDs) across the whole workspace, not just one repo — noisy logs often originate in a dependency, adapter, or vendored copy, not the code the user is staring at.

```
grep -rn "the distinctive literal part" <workspace-root>
```

If the message is templated (`%s`, `{}`, f-strings), search for the surrounding literal fragments, not the whole string. Note every call site if there are duplicates.

### 2. Trace it to the real source, not just the log statement

The line doing `log.Error(...)` is often just forwarding an `err` that was constructed somewhere else — a wrapped/joined error, an error-collector result, a formatted string built deep in a different call. Don't stop at the first match:

- Read the function containing the log call. Is `err` passed in, or joined/aggregated from multiple sub-errors (errgroup, waitgroup, error collector)?
- If aggregated, find **every** place that can produce that error text — there's often more than one, and they may all be identical (see step 3).
- Follow the call chain upward and downward: who calls the function that logs, and what does the function that builds the error actually check?
- If the repo is a fork/vendor of an upstream project, check `git remote -v` to see whether the code you're reading is upstream-owned or the user's own fork/wrapper — this affects where a fix should land (step 5).

### 3. Explain *why* it repeats, specifically

"Noisy" almost always means one of these patterns — identify which one, concretely, by reading the code (don't guess):

- **Fan-out burst**: one failure condition trips N independent sub-operations (goroutines/promises/futures in a batch, list of fields each queried separately), and each one logs its own copy of the same message. One real event → N log lines. Look for loops over `Errors()`/results collections that log per-item.
- **Tight retry/poll loop**: a ticker, retry loop, or reconciler re-triggers the same failing operation on a short interval with no backoff.
- **Persistent broken state**: something is misconfigured or a race leaves the system in a permanently-failing state (e.g. two independent schedules/tickers that assume synchronization but aren't actually synchronized), so the error fires on every cycle indefinitely rather than once.
- **Misleading/collapsed formatting**: the message itself obscures useful detail (e.g. truncating a sub-hour duration to integer hours, producing a constant "0h" regardless of actual value) — this doesn't cause the noise but makes different root causes look identical, hiding the real pattern.

State which pattern(s) apply, backed by the specific lines of code that prove it (loop, ticker interval, format verb, etc.) — not just "it's probably a race."

### 4. Identify root-cause hypotheses, grounded in code

Read the surrounding scheduling/config/call-path code to propose *why* the triggering condition happens (e.g. two unsynchronized tickers, a config flag enabling a code path without its prerequisite, a caller passing a value the callee doesn't support). Rank hypotheses by how directly the code supports them. Be explicit about what's confirmed by reading code vs. what would need runtime/log evidence (timestamps, env var values) to confirm — don't overclaim certainty you don't have.

### 5. Present options, cheapest-safe first

Always give the user a menu, roughly in this order, and recommend one:

1. **Systemic fix** — fix the actual triggering condition, if it's cheap and safe (e.g. synchronize the two schedules, fix the config mismatch, make the callee handle the caller's input). Best outcome, but may be bigger/riskier — say so.
2. **Consolidate the fan-out** — if pattern is "one event → N log lines" (step 3, fan-out), collapse at the point where the N results are gathered: dedupe by message text, log once with an occurrence count. This is usually small, safe, and kills most of the noise even if the root cause isn't fixed yet.
3. **Fix misleading formatting** — cheap, orthogonal to noise volume, but makes the next investigation faster (real values instead of truncated/collapsed ones).
4. **Log-level change** — last resort if the condition is expected/benign; drop from Error to Warn/Debug. Doesn't reduce volume, just visibility/alerting impact.

Note which repo/module each option lands in (own fork vs. upstream OSS the user doesn't control vs. their own service) — this affects effort and whether it needs a PR upstream.

Ask the user which option(s) to implement and where, rather than assuming — especially when a systemic fix spans a schedule/config change that needs runtime confirmation, or when the log line's source repo isn't the user's own.

### 6. Implement, verify, report

- Make the smallest change that satisfies the chosen option(s).
- Build/compile and run the narrowest relevant existing tests (don't invent new test infra for a logging tweak unless asked).
- Show the diff. Report concisely: what changed, in which file(s)/repo(s), and what the user should now expect to see in logs.

## Notes

- Don't treat "add a comment explaining what changed" as optional busywork, but don't over-comment either — one line on *why* the dedupe/collapse exists is enough; the diff itself shows *what*.
- If grepping across repos, check each repo's remote (`git remote -v`) to know which ones are upstream OSS vs. the user's own — never touch upstream without asking.
- Resist jumping straight to a log-level bump as the first offer — it's the last resort, not the default, because it hides the volume rather than reducing it.
