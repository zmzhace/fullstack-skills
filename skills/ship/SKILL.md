---
name: ship
description: "Verified release: runs full test suite, checks coverage, syncs main, pushes, opens PR. Hard gate: no PR without passing test terminal output."
---

# Ship — Verified Release

No assertions without evidence. Show the output, then ship.

## Process Flow

```dot
digraph ship {
    rankdir=TB;
    start   [label="Pre-flight check", shape=doublecircle];
    branch  [label="On main/master?", shape=diamond];
    stop    [label="STOP:\ncreate feature branch first", shape=box];
    step1   [label="Step 1: Run full test suite", shape=box];
    pass    [label="All tests pass?", shape=diamond];
    fix     [label="Fix failures", shape=box];
    step2   [label="Step 2: Check coverage", shape=box];
    thresh  [label="Meets threshold?", shape=diamond];
    over    [label="OVERRIDE or\n--skip-coverage?", shape=diamond];
    step3   [label="Step 3: Sync with main", shape=box];
    conf    [label="Conflicts?", shape=diamond];
    resolve [label="Resolve conflicts\nreturn to Step 1", shape=box];
    step4   [label="Step 4: Push + Open PR", shape=box];
    step5   [label="Step 5: Confirm\n(show PR URL + stats)", shape=doublecircle];

    start -> branch;
    branch -> stop [label="yes"];
    branch -> step1 [label="no"];
    step1 -> pass;
    pass -> fix [label="no"];
    fix -> step1;
    pass -> step2 [label="yes"];
    step2 -> thresh;
    thresh -> step3 [label="yes"];
    thresh -> over [label="no"];
    over -> step3 [label="yes / --skip-coverage"];
    over -> step2 [label="no, fix coverage"];
    step3 -> conf;
    conf -> resolve [label="yes"];
    resolve -> step1;
    conf -> step4 [label="no"];
    step4 -> step5;
}
```

## Pre-Flight Check

Before anything else, check the current branch:
- If on `main` or `master`: **stop immediately**.
  > "You're on `main`. Create a feature branch first: `git checkout -b feat/<name>`. Then re-run `/ship`."
- If the branch has no commits ahead of main: warn and confirm before proceeding.

<HARD-GATE>
Cannot open a PR without showing actual passing test terminal output. If tests fail: fix them. Come back. Do not open a PR with failing tests under any circumstances.
</HARD-GATE>

## Step 1: Run the Full Test Suite

Run the complete test suite using the same test runner discovery order as `/review` (package.json → Makefile → pyproject.toml → pytest.ini → go.mod → Cargo.toml → build.gradle/pom.xml). Show the actual terminal output in full — do not summarize, paraphrase, or infer.

If any test fails:
> "Tests are failing. Fix the failures before shipping."
> [show the full failure output]

Do not proceed to Step 2 until all tests pass and you have shown the green output.

## Step 2: Check Coverage

After tests pass, run coverage and show the report.

**Default threshold: 80%**

Threshold resolution order (stop at first match):
1. Project's own coverage config (`jest.config.js` coverageThreshold, `pyproject.toml [tool.coverage]`, `codecov.yml`, `.nycrc`)
2. `.fullstack` config file with key `coverage_threshold: <number>`
3. `COVERAGE_THRESHOLD` environment variable
4. Default: 80%

If coverage meets threshold: proceed.

If coverage is below threshold:
> "Coverage is X% — below the Y% threshold.
> Respond with OVERRIDE to proceed anyway, or re-run as `/ship --skip-coverage`."

If `--skip-coverage` was passed by the user when invoking this skill: skip this step entirely and proceed to Step 3.

Wait for explicit response. Do not proceed without it.

## Step 3: Sync with Main

```bash
git fetch origin
git rebase origin/main   # preferred — keeps history linear
# or: git merge origin/main — if the repo convention uses merge commits
```

Check `git log --oneline origin/main..HEAD` first. If the branch has already been rebased and is clean, skip this step.

If conflicts exist: resolve them, then return to Step 1 (re-run the full test suite after rebasing/merging).

## Step 4: Push and Open PR

```bash
git push origin <current-branch-name>
```

Open a PR with this description structure:

```markdown
## Summary
- [what this change does, one bullet per logical change]
- [why it was built — the user pain it addresses]

## Changes
- `path/to/file`: [what changed and why]

## Test Coverage
- [what the new/changed tests cover]
- Coverage: X%

## How to Test
1. [step-by-step manual verification]
2. [expected result at each step]
```

## Step 5: Confirm

Show the PR URL and state:
> "Shipped. PR: [URL]
> Tests: [N passing]. Coverage: X%."

Only say "Shipped" after you have shown:
1. The passing test output from Step 1
2. The PR URL from Step 4
