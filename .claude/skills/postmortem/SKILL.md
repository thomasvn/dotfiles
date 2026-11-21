---
name: postmortem
description: When an agent got something wrong, find which doc, rule, skill, test, or missing check let it happen and fix that first — before fixing the code. Use when the user says "postmortem", "why did you do that", "you keep doing X", "that was wrong, fix the system", or invokes /postmortem. Works on this session's context or a night-shift log.
---

# Postmortem

Goal: the same mistake never happens twice. Fix the system, then the code.

1. **State the miss** in one line: what was expected vs what was done. If unclear, ask once.
2. **Trace it.** Look at this session's context (or the log at `~/.claude/night-shift/<repo>-<date>.log` if given). Find the moment it went wrong and what you were relying on: which instruction, doc, skill, or missing information. Quote it.
3. **Classify the root cause** (pick one):
   - Missing/wrong doc (CLAUDE.md, SPEC.md, docs/)
   - Ambiguous or conflicting rule (global `~/.claude/CLAUDE.md`, project CLAUDE.md, a skill)
   - Missing validation (no test, lint rule, typecheck, or review-persona check would have caught it)
   - Spec gap (the human's spec didn't say)
   - Agent ignored a clear rule (say so plainly; suggest making it a check instead of prose)
4. **Propose the system fix** — the smallest edit to the doc, rule, skill, test, or check. Prefer an automated check over prose. Show it as a diff. Apply it once the user agrees (for global CLAUDE.md, follow the update-claude-md skill).
5. **Then fix the original issue**, and confirm the new check/test catches the old behavior.

Output: ≤10 lines — miss, root cause (quoted source), system fix, code fix status.
