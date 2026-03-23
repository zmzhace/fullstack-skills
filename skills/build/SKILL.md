---
name: build
description: "Implements the plan using strict TDD. Hard gate: no application logic without a failing test first. Run after /plan, before /review."
---

# Build — Test-Driven Implementation

Implement the plan task by task. Red → Green → Commit.

## Starting Check

Look for the latest plan in `docs/plans/` using this resolution order:
1. Sort files matching `docs/plans/YYYY-MM-DD-*.md` by filename descending
2. If multiple files share the same date, ask the user to select
3. If no files match the pattern, prompt: "No plan found. Enter path manually, or run `/plan` first."

If a plan is found but not required:
> "No plan found in `docs/plans/`. I recommend running `/plan` first. Continue anyway? (y/n)"

## The Hard Gate

**No application logic or business rule implementation without a failing test first.**

This applies to: functions, classes, API handlers, data transformations, validation logic, business rules.

This does NOT apply to: database migrations, environment config files, generated code, infrastructure definitions, CSS/styling. For these, document what you changed and why in a comment.

If you find yourself writing implementation without a failing test — stop. Write the test first.

## The TDD Loop

For each task in the plan, repeat:

**1. Write the failing test**
- Write the smallest test that proves the specific behavior
- Run it — verify it FAILS with a meaningful error (not a syntax error)
- If it passes immediately, your test is wrong — fix it

**2. Write minimal implementation**
- Write only enough code to make the test pass
- No extra logic, no "while I'm here" additions
- If you're writing code that no test exercises, stop and write the test first

**3. Verify green**
- Run the test — verify it passes
- Run the full test suite — verify nothing regressed

**4. Commit**
```bash
git add <test-file> <implementation-file>
git commit -m "feat: [what this task implements]"
```

**5. Move to next task**

## Unit Design Rules

Each unit (function, class, module) must:
- Have one clear purpose expressible in one sentence
- Be understandable without reading its internals
- Be independently testable without setting up unrelated state

If you can't describe what a unit does in one sentence, it's doing too much. Split it.

## TDD Applicability

The "failing test first" rule applies to application logic and business rules only.

Exceptions — document instead of test:
- **Database migrations** → comment explaining what the migration does and why
- **Environment/config files** → comment explaining each setting's purpose
- **Generated code** → note what generates it and how to regenerate
- **Infrastructure definitions** → describe the resource and its intended state

## Chaining

After completing all tasks:
> "Build complete. Run `/review` for production bug, security, and plan compliance checks before shipping."
