---
name: review
description: "Three-pass code review: production bugs (Staff Engineer), security threats (OWASP+STRIDE), and plan compliance. Auto-fixes style issues, flags logic and security for human approval."
---

# Review — Multi-Perspective Quality Gate

Three passes: production bugs, security threats, plan compliance. Auto-fix what's safe. Flag the rest.

## Starting Check

Look for the latest plan in `docs/plans/` (sort `YYYY-MM-DD-*.md` by filename descending) for the plan compliance pass.

If no plan found: warn and skip the compliance pass.
> "No plan found in `docs/plans/` — skipping plan compliance pass. Running production bug and security passes only."

## Pass 1: Staff Engineer — Production Bugs

Think like a Staff Engineer doing pre-production review. For every component changed, ask:

- **Race conditions**: Is any shared state accessed concurrently without synchronization?
- **Error handling**: What happens when this throws? Is every error path handled or explicitly ignored?
- **Edge cases**: Empty input, null values, max values, concurrent requests, network timeouts?
- **Resource leaks**: Are connections, file handles, and streams closed in all paths including errors?
- **Assumptions**: What does this code assume about its callers? Are those assumptions enforced?
- **N+1 queries**: Does any loop make database or API calls?
- **Validation gaps**: Is input validated at system boundaries, or trusted too far inside?

Label each finding: `FIXED`, `ASK`, or `INFO` (see Auto-Fix Rules below).

## Pass 2: Security Officer — OWASP + STRIDE

Only report findings where you can describe a **concrete exploit scenario** in this format:
> "Attacker: [who]. Vector: [how they reach it]. Impact: [what they achieve]."

If you cannot fill in all three fields with specifics, do not report the finding.

**OWASP Top 10** — check for:
- Injection (SQL, command, LDAP, template)
- Broken authentication / session management
- Sensitive data exposure (secrets in logs, unencrypted storage at rest)
- XML External Entity (XXE) if XML is parsed
- Broken access control (can User A access User B's data?)
- Security misconfiguration (debug mode on, default credentials, verbose errors)
- XSS (if any HTML is rendered or user content is reflected)
- Insecure deserialization
- Components with known vulnerabilities (check major dependency versions)
- Insufficient logging (are auth failures, access denials, and errors logged?)

**STRIDE** — for each trust boundary in the changed code:
- **Spoofing**: Can an attacker impersonate another user or service?
- **Tampering**: Can data be modified in transit or at rest without detection?
- **Repudiation**: Can a user deny an action with no audit trail?
- **Information Disclosure**: What sensitive data could leak through this change?
- **Denial of Service**: What can be exhausted or crashed by an unauthenticated request?
- **Elevation of Privilege**: Can a low-privilege user gain higher access through this code path?

All security findings are `ASK` — never auto-fix security issues.

## Pass 3: Plan Compliance

Compare the implementation against the latest plan:
- Are all tasks listed in the plan actually implemented?
- Are the acceptance criteria for each task met?
- Is there implemented code with no corresponding plan task? (scope creep — flag as `INFO`)

Gaps in implementation are `ASK`. Scope creep is `INFO`.

## Auto-Fix Rules

**AUTO-FIX without asking** (mechanical, reversible, no behavior change):
- Code style violations (formatting, indentation, trailing whitespace)
- Unused imports
- Missing return type annotations (when type is unambiguous)
- Obvious dead code with no side effects

After any auto-fix: run the test suite and show the output before continuing.

**Test runner discovery order** (stop at first match):
1. `package.json` → use `scripts.test`
2. `Makefile` → look for `test` target
3. `pyproject.toml` → run `pytest`
4. `pytest.ini` → run `pytest`

If no runner found: prompt the user for the test command before applying any auto-fix.

**ASK before changing** (requires human judgment):
- Any logic change
- Any interface change (function signature, API shape, data schema)
- All security findings
- Anything that changes observable behavior

## Output Format

```
## Review Report

### Pass 1: Production Bugs
FIXED: [what was auto-fixed and why it was safe to fix]
ASK: [finding] — [why it needs your decision] — Recommended: [option A] or [option B]
INFO: [observation — notable but not blocking]

### Pass 2: Security
ASK: [finding] — Exploit: [attacker] → [vector] → [impact]

### Pass 3: Plan Compliance
ASK: [task N from plan] — not found in implementation
INFO: [code with no corresponding plan task — possible scope creep]
```

## Chaining

After delivering the report:
> "Review complete. Address the ASK items above. When resolved, run `/ship` to verify and push."
