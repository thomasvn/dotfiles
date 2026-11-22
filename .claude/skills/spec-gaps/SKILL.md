---
name: spec-gaps
description: Review a spec the user wrote by hand and return only a short checklist of gaps — never rewrite or edit the spec. Use when the user says "check my spec", "what's missing from this spec", "spec gaps", "is this ready for night shift", or invokes /spec-gaps with a file path. For designing a spec with the agent driving, use feature-spec instead.
---

# Spec Gaps

The user writes the spec; you only point at holes. Do not edit the file, propose a rewrite, or design the solution.

1. Read the spec, plus CLAUDE.md and code it references (enough to spot contradictions with reality).
2. Ask: could an agent implement this overnight, with no questions, and write tests that prove it's done?
3. Return a checklist, at most 10 items, highest risk first. Each item is one line: the gap and the question that closes it.

```markdown
- [ ] Failure path: what happens when <X> times out — retry, skip, or exit 1?
- [ ] Success criteria: "fast" — what number?
- [ ] Contradiction: spec says <A>, triptok.py:120 does <B>. Which wins?
```

Look for: undefined success criteria, missing failure/edge cases, unstated non-goals, contradictions with existing code or docs, decisions left open, no way to test it.

End with one line: `Ready for [night]` or `Not ready: N blocking gaps`.
