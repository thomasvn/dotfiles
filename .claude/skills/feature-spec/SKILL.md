---
name: feature-spec
description: Design a feature from scratch through a disciplined process — Frame → Options → Critique → Spec — writing a living SPEC.md the whole way. Use when the user wants to plan/design a new feature, project, or system before building; says "spec this out", "design this", "write a spec", "plan this feature", "let's design X from scratch"; or invokes /feature-spec. Not for reviewing existing code.
---

# Feature Spec

Turn a vague feature idea into a reviewed, buildable spec. The output is always a **living `SPEC.md`** in the project root, grown through four phases. Design happens on paper (and with the user) *before* code — the spec is the artifact the user reviews and approves.

## Core rules (non-negotiable)

1. **Everything goes into `SPEC.md`** in the project root — not just chat. Create it in Phase 1, update it every phase. It is the single source of truth. (If the repo `.gitignore` excludes `SPEC.md`, fix that — it's a tracked artifact.)
2. **Plan before build.** Never jump to implementation. Present the plan and get explicit approval first. Each phase ends with the user; you propose, they steer.
3. **Ask, don't assume, on decisions that change the outcome.** Use `AskUserQuestion` for real forks (approach, scope, tech choice). Put your recommended option first, labelled "(Recommended)". Don't ask about things with an obvious default — pick it and say so.
4. **Non-goals are as important as goals.** Every spec states explicitly what it will NOT do. Scope discipline is the point.
5. **Prefer the simplest thing that works.** Shell out to existing tools over new deps; additive layers over rewrites. Justify any complexity in the spec.
6. **Validate locally before relying on CI / calling it done.** Reproduce build and test steps on the machine.

## The four phases

Walk them in order. Each writes its own section of `SPEC.md`. Don't skip ahead — a good Critique depends on a real Options pass, which depends on a tight Frame.

### Phase 1 — Frame
Pin down the problem before any solution.
- **Problem** — what's broken / missing, in one or two sentences.
- **Users** — who, and their relevant constraints (CLI-comfortable? offline? etc.).
- **Scope** — the handful of things it WILL do.
- **Non-goals** — explicit exclusions. Be generous here.
- **Success criteria** — concrete, checkable ("copy 3 things → pick the oldest → it pastes").

Write the `SPEC.md` skeleton now (see `templates/spec.md`). Mark status `DRAFT — Frame`. Confirm the frame with the user before moving on — a wrong frame wastes everything downstream.

### Phase 2 — Options
For each meaningful decision (language, storage, capture method, UI surface, …):
- Enumerate **≥2 approaches**.
- Lay them in a **tradeoff table** (columns: choice / pros / cons or rejected-because).
- **Recommend one** and say why.
Use `AskUserQuestion` to lock the choices that matter — bundle several into one call. Record the decisions (chosen + rejected) in the spec. This is where over-engineering dies: if sqlite/native-UI/a-daemon isn't earning its keep against a simpler option, reject it on the record.

### Phase 3 — Critique
Adversarial pass on the chosen design. Actively hunt for what breaks:
- Edge cases (empty, huge, concurrent, malformed, unicode/newlines).
- Failure modes (dependency missing, permission denied, partial write, race).
- Security/privacy (secrets, injection, what's captured/logged).
- Over-build (anything in the design not traceable to a goal → cut it).
- Operational (autostart, permissions the user must grant, cleanup).
List each concern with its mitigation or an explicit "accepted risk, v1" note. A critique with zero findings means you didn't try hard enough.

### Phase 4 — Spec (design detail)
Now the buildable detail:
- **Structure** — files/modules/dirs.
- **Data model** — schemas, formats, on-disk layout.
- **Flows** — step-by-step for each main path.
- **Interfaces** — commands/APIs, args, exit codes.
- **Open questions** — anything still undecided; resolve them (ask the user) before implementation, then move them to a "Resolved decisions" list.

Flip status to `READY` and hand to the user for approval. Only after approval: build. As you build, keep `SPEC.md` current (status → `IMPLEMENTED`, note what's tested/shipped).

## After the spec
- Distill durable, cross-project learnings the user confirms into memory (preferences, conventions) — not one-off details.
- If the project has a `CLAUDE.md`, record project conventions there too.

## Template
`templates/spec.md` — the section skeleton. Copy it to the project root as `SPEC.md` in Phase 1 and fill in as you go.
