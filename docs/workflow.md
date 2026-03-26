# Forge — Workflow Guide

A full example of Forge skills in action, from idea to merged PR.

## The Core Loop

```
/think → /plan → /build → /review → /ship → /sync
```

Each skill produces output that feeds the next. Run them in order for new features. Run any skill individually when you need a specific capability.

### Supporting Skills

| Need | Skill |
|------|-------|
| Hit a bug | `/debug` before any fix |
| About to claim "done" | `/verify` first |
| Received PR review | `/respond` to evaluate before implementing |
| Plan has independent tasks | `/delegate` for parallel execution with review gates |
| End of week | `/retro` for team summary + one action item |

---

## Example: Adding Rate Limiting to an API

### /think

```
You: /think
     I want to add rate limiting to my API
```

The skill presents six questions at once:

1. "What specific frustration triggered this? Describe the last time it caused a problem."
   → "A bot scraped our user data endpoint 50,000 times in an hour. Cost us $800 in compute."

2. "Who exactly has this pain?"
   → "Our platform team, on-call rotation, 2-3 times a month now."

(... four more questions ...)

After the questions, the skill reframes: "You're not building rate limiting — you're building abuse prevention. The rate limit is one mechanism; the real goal is cost and data protection."

Proposes three approaches with effort and trade-offs. You choose. Spec written to `docs/specs/2026-03-23-rate-limiting.md`.

Self-review runs automatically: checks for placeholders, contradictions, scope issues. Clean — handoff confirmed.

---

### /plan

```
You: /plan
```

Reads the spec. Produces:

**Data flow diagram:**
```
[Request] → [Rate Check Middleware] → [Handler]
                    ↓
             [Redis Counter]
             (key: ip:endpoint:window)
```

**Edge cases enumerated:** Redis unavailable (fail open vs fail closed), concurrent increments (atomic ops), clock skew across instances, IPv6, requests behind proxies (X-Forwarded-For).

**4 tasks decomposed**, each under 2 hours, with acceptance criteria.

Plan self-review runs automatically: checks spec coverage, file path consistency, task ordering. All good.

Plan written to `docs/plans/2026-03-23-rate-limiting.md`.

---

### /build

```
You: /build
```

Reads the plan. For Task 1 (Redis counter):

1. Writes failing test: `test_increment_returns_new_count_and_ttl`
2. Runs it — FAIL: `ImportError: no module named 'rate_limiter'`
3. Writes minimal implementation
4. Runs test — PASS
5. Runs full suite — all green
6. Refactors: extracts `WINDOW_SECONDS` constant
7. Runs full suite again — still green
8. Commits: `feat: add Redis counter with atomic increment and TTL`

Repeats for all 4 tasks.

---

### /debug (if something breaks during /build)

```
You: /debug
     test_concurrent_requests is flaky — passes sometimes, fails others
```

Phase 1 — Root cause: two Redis commands (`INCR` + `EXPIRE`) are not atomic. Under concurrent load, a window can reset mid-flight.

Phase 2 — Pattern: finds existing atomic pattern in codebase using `MULTI/EXEC`.

Phase 3 — Hypothesis: "Replace INCR+EXPIRE with a Lua script for atomic increment-and-set."

Phase 4 — Writes failing test for the race condition, applies single fix, verifies.

---

### /verify

```
You: /verify
```

Before claiming Task 2 complete:

1. Runs the task's specific test — shows output: `3/3 passing`
2. Runs full suite — shows output: `31/31 passing`
3. States: "Verified. Task 2 complete."

No "should work now." Evidence only.

---

### /review

```
You: /review
```

**Pass 1 (Production Bugs):**
- ASK: `incr` and `expire` are two separate Redis commands — not atomic. Under concurrent load, a request could slip through after `incr` but before `expire`. Recommend `MULTI/EXEC` pipeline.
- INFO: No logging on rate limit hits — consider adding for observability.

**Pass 2 (Security):**
- ASK: `X-Forwarded-For` header is trusted directly. Exploit: Attacker spoofs header → bypasses rate limit entirely. Should only trust this header behind known proxy IPs.

**Pass 3 (Plan Compliance):**
- All 4 tasks implemented. Acceptance criteria met.

You approve both ASK fixes. Applied. Tests re-run — green.

---

### /respond (if you receive PR feedback after /ship)

```
Reviewer: "The Redis key format should use : not . as separator — industry standard"
```

`/respond` evaluates:
- Checks codebase: existing keys use `.` consistently everywhere else
- Not a bug, just a style preference
- Counter: "Our existing keys use `.` for consistency. The `:` convention is common but not universal. Open to changing if the team wants to standardize — but it's not wrong as-is."

No performative "you're absolutely right!" — technical evaluation first.

---

### /ship

```
You: /ship
```

1. Pre-flight check — confirms not on main branch ✓
2. Runs full test suite — shows output: `47 passed in 3.2s` ✓
3. Coverage: 84% — above 80% threshold ✓
4. Checks `git log --oneline origin/main..HEAD` — already synced ✓
5. Pushes branch, opens PR with structured description
6. Shows: `Shipped. PR: github.com/you/api/pull/31. Tests: 47 passing. Coverage: 84%.`

---

### /sync

```
You: /sync
```

Reads git diff since last release. Updates:
- `README.md` — adds rate limiting to the "Features" section
- `CHANGELOG.md` — adds entry under `[Unreleased] → Added`
- `docs/api.md` — documents the new `X-RateLimit-*` response headers

Commits: `docs: update documentation for rate-limiting release`

---

## Running Skills Individually

Any skill runs standalone:

```
/review          ← review a branch you built without /build
/ship            ← ship any branch with passing tests
/think           ← explore an idea without committing to build it
/debug           ← debug any issue without a full build cycle
/retro           ← run a weekly retro any time
```

## Output Files Created

| Skill | Output location |
|-------|----------------|
| `/think` | `docs/specs/YYYY-MM-DD-<topic>.md` |
| `/plan` | `docs/plans/YYYY-MM-DD-<topic>.md` |
| `/build` | Source files + test files + commits |
| `/review` | Inline report in terminal |
| `/ship` | Git push + PR URL |
| `/sync` | Updated doc files + commit |
| `/retro` | `docs/retros/YYYY-MM-DD.md` |
