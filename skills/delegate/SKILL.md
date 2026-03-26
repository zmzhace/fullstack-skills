---
name: delegate
description: "Use when executing a plan task-by-task with isolated agents, or dispatching multiple agents in parallel for independent problems. Two modes: sequential (one subagent per task + two-stage review) and parallel (concurrent agents for unrelated failures)."
---

# Subagent — Isolated Execution with Review Gates

You delegate tasks to agents with precisely crafted, isolated context. They never inherit your session history — you construct exactly what they need. This keeps each agent focused and preserves your context for coordination.

**Three modes:**
- **Sequential** — Execute a plan task by task. Fresh subagent per task + two-stage review (spec compliance → code quality) after each.
- **Inline** — Execute a plan directly in this session, batch by batch, with a checkpoint after each batch. Simpler, no subagent overhead.
- **Parallel** — Dispatch multiple agents concurrently for independent problems.

## When to Use Which Mode

```dot
digraph mode_select {
    start   [label="What's the task?", shape=doublecircle];
    plan    [label="Executing an\nimplementation plan?", shape=diamond];
    indep   [label="Multiple independent\nfailures/problems?", shape=diamond];
    qual    [label="Need maximum\nquality gates?", shape=diamond];
    seq     [label="Sequential mode\n(subagent per task)", shape=box, style=filled, fillcolor="#cce0ff"];
    inline  [label="Inline mode\n(current session, checkpoints)", shape=box, style=filled, fillcolor="#fffacc"];
    par     [label="Parallel mode\n(concurrent agents)", shape=box, style=filled, fillcolor="#ccffcc"];
    build   [label="Just run /build\n(single task, no plan)", shape=box];

    start -> plan;
    plan -> qual [label="yes"];
    qual -> seq [label="yes, review gates\nafter every task"];
    qual -> inline [label="no, checkpoints\nare enough"];
    plan -> indep [label="no"];
    indep -> par [label="yes, independent"];
    indep -> build [label="no, single task"];
}
```

---

## Sequential Mode — Plan Execution

Execute a plan from `docs/plans/` one task at a time. Fresh subagent implements each task; two reviewers check the result before moving on.

**Core principle:** Fresh subagent per task + spec compliance first + code quality second = high quality without context pollution.

### Process Flow

```dot
digraph sequential {
    rankdir=TB;
    read    [label="Read plan\nExtract ALL tasks upfront", shape=box];
    task    [label="Next task", shape=box];
    impl    [label="Dispatch implementer subagent\n(full task text + codebase context)", shape=box];
    q       [label="Subagent\nhas questions?", shape=diamond];
    ans     [label="Answer questions\nre-dispatch", shape=box];
    status  [label="Subagent status?", shape=diamond];
    spec    [label="Dispatch spec reviewer\n(does code match spec?)", shape=box];
    specok  [label="Spec compliant?", shape=diamond];
    fixspec [label="Implementer fixes\nspec gaps", shape=box];
    qual    [label="Dispatch quality reviewer\n(code quality check)", shape=box];
    qualok  [label="Quality approved?", shape=diamond];
    fixqual [label="Implementer fixes\nquality issues", shape=box];
    done1   [label="Mark task complete", shape=box];
    more    [label="More tasks?", shape=diamond];
    final   [label="Final review of\nentire implementation", shape=box];
    ship    [label="Run /ship", shape=doublecircle];

    read -> task;
    task -> impl;
    impl -> q;
    q -> ans [label="yes"];
    ans -> impl;
    q -> status [label="no"];
    status -> spec [label="DONE"];
    status -> ans [label="NEEDS_CONTEXT\nprovide info, re-dispatch"];
    status -> fixspec [label="BLOCKED\nassess and re-dispatch"];
    spec -> specok;
    specok -> fixspec [label="no"];
    fixspec -> spec [label="re-review"];
    specok -> qual [label="yes"];
    qual -> qualok;
    qualok -> fixqual [label="no"];
    fixqual -> qual [label="re-review"];
    qualok -> done1 [label="yes"];
    done1 -> more;
    more -> task [label="yes"];
    more -> final [label="no"];
    final -> ship;
}
```

### Implementer Prompt Template

When dispatching the implementer subagent, provide:

```
Task: [Task N name from plan]

Codebase context:
- Tech stack: [language, framework, test runner]
- Relevant existing files: [list files the task touches]
- Conventions to follow: [test naming, import style, etc.]

Task specification:
[Full task text from the plan, verbatim — do NOT summarize]

Your job:
1. Implement using TDD (/build loop: failing test → minimal impl → refactor → commit)
2. Run the full test suite — all must pass before reporting done
3. Self-review: check for spec drift, dead code, obvious issues
4. Report status: DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED

Do NOT read any other plan or spec files — use only what's provided here.
```

### Spec Reviewer Prompt Template

```
Review the implementation of Task N against this spec:

[Full task text from plan, verbatim]

Changed files:
[List commits and changed files since last task]

Check only:
1. Does the implementation fulfill every requirement in the spec?
2. Is there anything in the spec that was NOT implemented?
3. Is there anything implemented that is NOT in the spec (over-building)?

Report: ✅ COMPLIANT or ❌ ISSUES with specific gaps listed.
Do NOT evaluate code quality — that's a separate review.
```

### Quality Reviewer Prompt Template

```
Review the code quality of this implementation (spec compliance already verified):

Changed files:
[List commits and changed files since last task]

Check for:
- Race conditions, resource leaks, error paths not handled
- N+1 queries, validation gaps
- Unit design: each function has one clear purpose?
- Naming clarity, obvious duplication

Report: ✅ APPROVED or ❌ ISSUES with specific findings.
Do NOT check spec compliance — that was already verified.
```

### Handling Subagent Status

| Status | Action |
|--------|--------|
| `DONE` | Proceed to spec review |
| `DONE_WITH_CONCERNS` | Read the concerns. If about correctness/scope, address first. If observations only, proceed to review. |
| `NEEDS_CONTEXT` | Provide the missing information, re-dispatch |
| `BLOCKED` | Assess: context problem → provide more + re-dispatch. Task too large → split. Plan wrong → escalate to user. |

**Never** ignore an escalation or re-dispatch the same subagent with no changes.

---

## Inline Mode — Direct Session Execution

Execute the plan in the current session. No subagent overhead. Uses checkpoints after each batch so you can review progress without losing context.

**Use when:** Plan is well-specified, tasks are mostly sequential, and you don't need per-task review gates.

### Process Flow

```dot
digraph inline {
    rankdir=TB;
    load    [label="Load plan\nRaise concerns before starting", shape=box];
    batch   [label="Execute next batch\n(1-3 related tasks)", shape=box];
    test    [label="Run test suite", shape=box];
    pass    [label="All green?", shape=diamond];
    debug   [label="Run /debug\nfix before continuing", shape=box];
    check   [label="Checkpoint:\nsummarize progress", shape=box];
    more    [label="More tasks?", shape=diamond];
    done    [label="Run /review then /ship", shape=doublecircle];

    load -> batch;
    batch -> test;
    test -> pass;
    pass -> debug [label="no"];
    debug -> test;
    pass -> check [label="yes"];
    check -> more;
    more -> batch [label="yes"];
    more -> done [label="no"];
}
```

### Steps

**1. Load and review the plan**
Read the full plan. If anything is unclear or contradictory, raise it before starting — not mid-execution.

**2. Execute in batches**
Group 1-3 related tasks per batch. For each task, follow the TDD loop from `/build` (failing test → minimal impl → refactor → commit). Do not skip the commit.

**3. Run the full test suite after each batch**
If any test fails, stop immediately. Run `/debug` to find root cause before continuing. Do not bundle bug fixes into the next batch.

**4. Checkpoint**
After each batch, summarize:
```
Batch N complete:
- Tasks done: [list]
- Tests: N passing
- Remaining: [list]
- Any concerns: [or "none"]
```

**5. Stop when blocked**
If a task has a missing dependency, unclear instruction, or failing test that can't be explained — stop and ask. Do not guess or push through.

---

## Parallel Mode — Independent Problems

When multiple unrelated failures exist across different subsystems, investigate them concurrently rather than sequentially.

### When to Use Parallel Mode

**Use when:**
- 2+ test files failing with different root causes
- Multiple subsystems broken independently
- Each problem can be understood without context from the others
- No shared state — agents won't edit the same files

**Don't use when:**
- Failures are related (fixing one might fix others)
- You don't yet know what's broken (explore first)
- Agents would touch the same files (causes conflicts)

### Process Flow

```dot
digraph parallel {
    start   [label="Identify independent\nproblem domains", shape=doublecircle];
    group   [label="Group failures\nby domain", shape=box];
    dispatch [label="Dispatch one agent\nper domain (all at once)", shape=box];
    wait    [label="Wait for all\nagents to return", shape=box];
    review  [label="Review each summary\ncheck for conflicts", shape=box];
    suite   [label="Run full test suite", shape=box];
    ok      [label="All green?", shape=diamond];
    fix     [label="Investigate conflict\nor remaining failure", shape=box];
    done    [label="Done", shape=doublecircle];

    start -> group;
    group -> dispatch;
    dispatch -> wait;
    wait -> review;
    review -> suite;
    suite -> ok;
    ok -> done [label="yes"];
    ok -> fix [label="no"];
    fix -> suite;
}
```

### Agent Prompt Template

```
Fix the failing tests in [specific file or subsystem]:

Failures:
1. "[test name]" — [error message]
2. "[test name]" — [error message]

Your scope: ONLY [this file / this subsystem]. Do not change other code.

Your task:
1. Read the failing tests and understand what each verifies
2. Identify the root cause — don't just fix symptoms
3. Fix the root cause
4. Run the suite for this file: all tests must pass
5. Return: what you found, what you changed

Do NOT increase timeouts as a fix. Do NOT change test expectations unless the behavior deliberately changed.
```

### After Agents Return

1. **Read each summary** — understand what changed
2. **Check for conflicts** — did any agents touch the same files?
3. **Run the full test suite** — verify all fixes work together
4. **Spot-check** — agents can make systematic errors; review diffs

---

## Rules for Both Modes

**Never:**
- Let subagents inherit your session context — construct their prompt explicitly
- Start implementation on `main` / `master` without explicit user consent
- Skip the review loops in sequential mode (both spec + quality required)
- Dispatch parallel agents that edit the same files
- Accept "close enough" on spec compliance — not done until ✅
- Move to the next task while the current task has open review issues

**Always:**
- Answer subagent questions fully before letting them proceed
- Provide the complete task text verbatim — don't summarize
- Run the full test suite after integrating parallel agents

## Chaining

After all tasks complete (sequential) or all agents return (parallel):
> "All tasks complete. Run `/review` for the full three-pass quality gate, then `/ship`."
