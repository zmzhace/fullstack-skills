---
name: ship
description: "Verified release: runs full test suite, checks coverage, syncs main, pushes, opens PR. Hard gate: no PR without passing test terminal output."
---

# Ship — Verified Release

No assertions without evidence. Show the output, then ship.

## The Hard Gate

**Cannot open a PR without showing actual passing test terminal output.**

If tests fail: fix them. Come back. Do not open a PR with failing tests under any circumstances.

## Step 1: Run the Full Test Suite

Run the complete test suite. Show the actual terminal output in full — do not summarize, paraphrase, or infer.

If any test fails:
> "Tests are failing. Fix the failures before shipping."
> [show the full failure output]

Do not proceed to Step 2 until all tests pass and you have shown the green output.

## Step 2: Check Coverage

After tests pass, run coverage and show the report.

**Default threshold: 80%**

Override options (checked in this order):
1. `COVERAGE_THRESHOLD` environment variable
2. `.fullstack` config file with key `coverage_threshold: <number>`

If coverage meets threshold: proceed.

If coverage is below threshold:
> "Coverage is X% — below the Y% threshold.
> Respond with OVERRIDE to proceed anyway, or re-run as `/ship --skip-coverage`."

Wait for explicit response. Do not proceed without it.

## Step 3: Sync with Main

```bash
git fetch origin
git merge origin/main
```

If merge conflicts exist: resolve them, then return to Step 1 (re-run the full test suite after merging).

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
