# Sprint Workflow Guide

A full example of fullstack-skills in action, from idea to merged PR.

## The Sprint

```
/think → /plan → /build → /review → /ship
```

Each skill produces output that feeds the next. Run them in order for new features. Run them individually when you need a specific capability.

---

## Example: Adding Rate Limiting to an API

### /think

```
You: /think
     I want to add rate limiting to my API
```

The skill asks six questions, one at a time:

1. "What specific frustration triggered this? Describe the last time it caused a problem."
   → "A bot scraped our user data endpoint 50,000 times in an hour. Cost us $800 in compute."

2. "Who exactly has this pain?"
   → "Our platform team, on-call rotation, 2-3 times a month now."

(... four more questions ...)

After the questions, the skill reframes: "You're not building rate limiting — you're building abuse prevention. The rate limit is one mechanism; the real goal is cost and data protection."

Proposes three approaches with effort and trade-offs. You choose. Spec written to `docs/specs/2026-03-23-rate-limiting.md`.

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
6. Commits: `feat: add Redis counter with atomic increment and TTL`

Repeats for all 4 tasks.

---

### /review

```
You: /review
```

**Pass 1 (Production Bugs):**
- ASK: `incr` and `expire` are two separate Redis commands — not atomic. Under concurrent load, a request could slip through after `incr` but before `expire`. Recommend `MULTI/EXEC` pipeline. Approve fix?
- INFO: No logging on rate limit hits — consider adding for observability.

**Pass 2 (Security):**
- ASK: `X-Forwarded-For` header is trusted directly for IP extraction. Exploit: Attacker spoofs header → bypasses rate limit entirely. Should only trust this header behind known proxy IPs.

**Pass 3 (Plan Compliance):**
- All 4 tasks implemented. Acceptance criteria met.

You approve both ASK fixes. They're applied. Tests re-run — green.

---

### /ship

```
You: /ship
```

1. Runs full test suite — shows output: `47 passed in 3.2s`
2. Coverage: 84% — above 80% threshold
3. Syncs main — no conflicts
4. Pushes branch, opens PR with structured description
5. Shows: `Shipped. PR: github.com/you/api/pull/31. Tests: 47 passing. Coverage: 84%.`

---

## Running Skills Individually

Any skill runs standalone:

```
/review          ← review a branch you built without /build
/ship            ← ship any branch with passing tests
/think           ← explore an idea without committing to build it
```

## Output Files Created

| Skill | Output location |
|-------|----------------|
| `/think` | `docs/specs/YYYY-MM-DD-<topic>.md` |
| `/plan` | `docs/plans/YYYY-MM-DD-<topic>.md` |
| `/build` | Source files + test files |
| `/review` | Inline fixes committed + report in terminal |
| `/ship` | Git push + PR URL |
