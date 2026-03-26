---
name: plan
description: "Turns a spec into architecture diagrams, edge case analysis, and bite-sized TDD-ready tasks. Run after /think, before /build."
---

# Plan — Architecture + Implementation Plan

Turn a spec into a concrete implementation plan with architecture diagrams, edge cases, and TDD-ready tasks.

## Process Flow

```dot
digraph plan {
    rankdir=TB;
    start   [label="Load spec", shape=doublecircle];
    found   [label="Spec found?", shape=diamond];
    warn    [label="Warn: no spec\nAsk to continue", shape=box];
    arch    [label="Step 1: Architecture diagrams", shape=box];
    valid   [label="Spec assumptions\nvalid?", shape=diamond];
    flag    [label="Flag issue\nAsk user", shape=box];
    edge    [label="Step 2: Edge cases\n& failure modes", shape=box];
    tasks   [label="Step 3: Task decomposition", shape=box];
    write   [label="Step 4: Write plan file", shape=box];
    rev     [label="Plan self-review", shape=box];
    issues  [label="Issues\nfound?", shape=diamond];
    fix     [label="Fix inline", shape=box];
    done    [label="Tell user: run /build", shape=doublecircle];

    start -> found;
    found -> arch [label="yes"];
    found -> warn [label="no"];
    warn -> arch [label="continue anyway"];
    arch -> valid;
    valid -> flag [label="no"];
    flag -> arch [label="continue anyway"];
    valid -> edge [label="yes"];
    edge -> tasks;
    tasks -> write;
    write -> rev;
    rev -> issues;
    issues -> fix [label="yes"];
    fix -> rev;
    issues -> done [label="no"];
}
```

## Starting Check

Look for the latest spec in `docs/specs/` using this resolution order:
1. Sort files matching `docs/specs/YYYY-MM-DD-*.md` by filename descending
2. If multiple files share the same date, ask the user to select
3. If no files match the pattern, prompt: "No spec found. Run `/think` first, provide a path, or paste your requirements inline to continue without a spec."

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

## Plan Self-Review

After writing the plan, review it yourself before telling the user to proceed. This is a checklist you run inline.

**1. Spec coverage** — skim each requirement in the spec. Can you point to a task that implements it? List any gaps and add missing tasks.

**2. Placeholder scan** — search for TBD, TODO, "implement later", "add appropriate", "similar to Task N". Every step must contain the actual content needed. Fix them.

**3. File path consistency** — do paths defined in early tasks match how they're referenced in later tasks? A file created as `src/auth/token.ts` in Task 2 but imported as `src/auth/tokens.ts` in Task 4 is a bug. Fix naming drift now.

**4. Task ordering** — does each task only depend on outputs from earlier tasks? If Task 3 needs something from Task 5, reorder or split.

Fix issues inline. No need to re-review after fixing — just correct and move on.

## Spec Feedback Loop

If during architecture analysis or edge case enumeration you discover that the spec's assumptions are invalid, scope is unrealistic, or a critical constraint was missed:

> "Spec issue found: [describe the problem]. This affects the plan because [why]. Recommend re-running `/think` to reframe before continuing."

Do not force a plan from a broken spec. Surface the issue and let the user decide.

## Chaining

After writing and self-reviewing the plan:
> "Plan written to `docs/plans/<filename>.md`. Run `/build` to implement task by task with TDD."
