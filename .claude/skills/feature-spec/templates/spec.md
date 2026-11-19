# <project> — SPEC

> Living spec. Produced by the feature-spec process (Frame → Options → Critique → Spec).
> Status: **DRAFT — Frame**

## 1. Frame

### Problem
<what's broken/missing, 1–2 sentences>

### Users
<who, and their relevant constraints>

### Scope
- <thing it will do>

### Non-goals
- <explicit exclusion>

### Success criteria
- <concrete, checkable outcome>

## 2. Options

| Dimension | Choice | Rejected / because |
|-----------|--------|--------------------|
| <e.g. storage> | <chosen> | <alternative — why not> |

<For a decision with real UX/architecture impact, enumerate the approaches and recommend one. Lock the important ones with the user.>

## 3. Critique
_(adversarial pass — each concern gets a mitigation or an explicit accepted-risk note)_

- <edge case / failure mode> → <mitigation | accepted risk, v1>

## 4. Design

### Structure
```
<files / modules / dirs>
```

### Data model
<schemas, formats, on-disk layout>

### Flows
- **<flow name>:** <step-by-step>

### Interfaces
- `<command/api>` — <args, behavior, exit codes>

## 5. Resolved decisions
- <question> → <answer + why>

## 6. Status
- <what's built / tested / shipped>
