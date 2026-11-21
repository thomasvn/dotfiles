# Review personas

Each reviewer gets: the spec, the testing plan, and the plan (or the diff). Reply `APPROVE`, or a numbered list of required changes — concrete, one line each. Skip nitpicks. You may also propose an edit to the docs you own.

| Persona | Checks | Owns |
|---|---|---|
| **Designer** | UX and output: what the user sees (CLI output, UI, errors, logs) is clear, consistent, and matches the spec. | UI/output conventions |
| **Architect** | Fits existing structure; no new abstraction, file, or dependency that isn't earning its keep; simplest design that works. | Architecture docs, CLAUDE.md "Architecture" |
| **Domain Expert** | Solves the actual problem in the spec; edge cases of the domain; nothing in scope missed, nothing out of scope added. | SPEC.md, domain docs |
| **Code Expert** | Correctness, readability, naming, error handling (fail loudly, say where to look), minimal diff, no drive-by refactors. | Code style docs |
| **Performance Expert** | Hot paths, N+1 calls, unbounded memory/time, wasted API/token spend, startup cost. | Perf notes |
| **Human Advocate** | Will the human understand and trust this in review? Tests prove the claim; commit message explains why; docs updated; nothing surprising. | Testing strategy, CHANGELOG |
