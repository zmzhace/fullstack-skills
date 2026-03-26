---
name: forge-build
description: "Implements the plan using strict TDD. Hard gate: no application logic without a failing test first. Run after /forge-plan, before /forge-review."
---

# Build — Test-Driven Implementation

Implement the plan task by task. Red → Green → Refactor → Commit.

## Process Flow

```dot
digraph build {
    rankdir=TB;
    start   [label="Load plan", shape=doublecircle];
    resume  [label="Resume check:\nmark completed tasks [done]", shape=box];
    task    [label="Next incomplete task", shape=box];
    red     [label="RED: Write failing test", shape=box, style=filled, fillcolor="#ffcccc"];
    run1    [label="Run test", shape=box];
    fails   [label="Fails with\nmeaningful error?", shape=diamond];
    fixtest [label="Fix test\n(wrong failure = wrong test)", shape=box];
    green   [label="GREEN: Write minimal impl", shape=box, style=filled, fillcolor="#ccffcc"];
    run2    [label="Run full suite", shape=box];
    allpass [label="All green?", shape=diamond];
    fiximpl [label="Fix implementation", shape=box];
    refact  [label="REFACTOR: Clean up", shape=box, style=filled, fillcolor="#cce0ff"];
    run3    [label="Run full suite again", shape=box];
    stillg  [label="Still green?", shape=diamond];
    undo    [label="Undo refactor\ntry smaller", shape=box];
    commit  [label="Commit", shape=box];
    more    [label="More tasks?", shape=diamond];
    done    [label="Tell user: run /forge-review", shape=doublecircle];

    start -> resume;
    resume -> task;
    task -> red;
    red -> run1;
    run1 -> fails;
    fails -> fixtest [label="no / passes immediately"];
    fixtest -> red;
    fails -> green [label="yes"];
    green -> run2;
    run2 -> allpass;
    allpass -> fiximpl [label="no"];
    fiximpl -> run2;
    allpass -> refact [label="yes"];
    refact -> run3;
    run3 -> stillg;
    stillg -> undo [label="no"];
    undo -> run3;
    stillg -> commit [label="yes"];
    commit -> more;
    more -> task [label="yes"];
    more -> done [label="no"];
}
```

## Starting Check

Look for the latest plan in `docs/plans/` using this resolution order:
1. Sort files matching `docs/plans/YYYY-MM-DD-*.md` by filename descending
2. If multiple files share the same date, ask the user to select
3. If no files match the pattern, prompt: "No plan found. Run `/forge-plan` first, provide a path, or describe the tasks inline to continue without a plan."

**Resuming a partial build:** Before starting, scan each task in the plan and check if its files already exist and its acceptance criteria are met. List completed tasks as `[done]` and begin from the first incomplete task. Do not re-implement tasks that already pass.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
(application logic only — see Exceptions below)
```

If you wrote implementation code before a failing test:
- **Delete it.** Not "keep as reference." Delete it.
- Start over with the test.
- No exceptions for application logic. Not even for "obvious" code.

This applies to: functions, classes, API handlers, data transformations, validation logic, business rules.

This does NOT apply to: database migrations, environment config files, generated code, infrastructure definitions, CSS/styling. For these, document what you changed and why in a comment (see TDD Applicability section).

Thinking "skip TDD just this once"? That's rationalization. Stop.

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

**4. Refactor**
- Review what you just wrote: rename for clarity, extract duplication, simplify conditionals
- Only touch code covered by the tests you just wrote — no drive-by refactors
- Run the full test suite again — still green? Proceed. Broke something? Undo and try a smaller refactor.

**5. Commit**
```bash
git add <test-file> <implementation-file>
git commit -m "<type>: [what this task implements]"
```
Choose the commit type based on the change: `feat:` for new functionality, `fix:` for bug fixes, `refactor:` for restructuring without behavior change, `test:` for test-only changes.

**6. Move to next task**

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

## When Implementation Breaks Down

If a task's implementation fails repeatedly and the root cause isn't a code bug but a design flaw (wrong abstraction, missing dependency, incorrect data model), **stop building and escalate**:

> "Task N is failing because [describe the design problem]. The current plan assumes [assumption] but the codebase shows [reality]. Recommend returning to `/forge-plan` to revise the affected tasks before continuing."

Do not force a broken design to pass tests. Surface the issue and let the user decide.

Signs you need to escalate to `/forge-plan`:
- Each fix reveals a new problem in a different component
- You're writing implementation that no reasonable test could exercise
- The plan's file structure no longer matches what you're actually building

## Chaining

After completing all tasks:
> "Build complete. Run `/forge-review` for production bug, security, and plan compliance checks before shipping."
