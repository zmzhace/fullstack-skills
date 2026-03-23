---
name: plan
description: "Turns a spec into architecture diagrams, edge case analysis, and bite-sized TDD-ready tasks. Run after /think, before /build."
---

# Plan — Architecture + Implementation Plan

Turn a spec into a concrete implementation plan with architecture diagrams, edge cases, and TDD-ready tasks.

## Starting Check

Look for the latest spec in `docs/specs/` using this resolution order:
1. Sort files matching `docs/specs/YYYY-MM-DD-*.md` by filename descending
2. If multiple files share the same date, ask the user to select
3. If no files match the pattern, prompt: "No spec found matching `YYYY-MM-DD-*.md`. Enter path manually, or run `/think` first."

If a spec is found but you want to proceed without one:
> "No spec found in `docs/specs/`. I recommend running `/think` first to define the problem. Continue anyway? (y/n)"

## Step 1: Architecture Diagrams

Draw ASCII diagrams for:

**Data flow** — how data moves through the system:
```
[Input] → [Component A] → [Component B] → [Output]
                ↓
           [Side effect]
```

**State machine** (if the feature has distinct states):
```
[State A] --event--> [State B] --event--> [State C]
              ↑                               |
              └───────────────────────────────┘
```

**Component relationships** — what depends on what:
```
[UI Layer]
    ↓
[Business Logic]
    ↓
[Data Layer]
```

Draw the diagrams that apply. Skip diagrams that add no information.

## Step 2: Edge Cases and Failure Modes

For each component, enumerate:
- What happens when input is empty, null, or malformed?
- What happens when a dependency is unavailable?
- What happens under concurrent load?
- What's the worst-case performance scenario?
- What error does the user see when this fails?

## Step 3: Task Decomposition

Break the work into TDD-ready tasks. Each task must:
- Have one clear deliverable (one sentence)
- List exact files to create or modify
- Be completable in under 2 hours
- Be independently testable

Task format:
```markdown
### Task N: [Name]
**Deliverable:** [one sentence — what this task produces]
**Files:**
- Create: `path/to/new/file`
- Modify: `path/to/existing/file`
**Acceptance criteria:** [what passing tests prove about this task]
```

## Step 4: Write the Plan

Write to `docs/plans/YYYY-MM-DD-<topic>.md`. Create `docs/plans/` if it doesn't exist.

```markdown
# [Feature] Implementation Plan

**Goal:** [one sentence]
**Architecture:** [2-3 sentences about approach]
**Tech Stack:** [key technologies]

---

## Architecture
[ASCII diagrams]

## Edge Cases
[enumerated list]

## Tasks
[task list]
```

## Chaining

After writing the plan:
> "Plan written to `docs/plans/<filename>.md`. Run `/build` to implement task by task with TDD."
