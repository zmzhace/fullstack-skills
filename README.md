# Forge

Eleven Claude Code skills for a complete software development workflow — from idea to shipped, maintained, and retrospected.

```
/think → /plan → /build → /review → /ship → /sync
                    ↓              ↑
                 /debug         /respond
                    ↓
                /verify
                         /delegate  (parallel execution)
                         /retro     (end of week)
```

## Skills

### Core Workflow

| Skill | Role | What it does |
|-------|------|--------------|
| `/think` | Product Thinking | Challenges your framing, extracts real pain, writes a spec with self-review |
| `/plan` | Architecture | ASCII diagrams, edge cases, TDD-ready task breakdown, self-review |
| `/build` | TDD Implementation | Red → Green → Refactor → Commit, Iron Law on application logic |
| `/review` | Quality Gate | Production bugs + OWASP/STRIDE security + plan compliance |
| `/ship` | Verified Release | Pre-flight check, tests, coverage, sync main, open PR |
| `/sync` | Docs Sync | Update README, API docs, CHANGELOG, guides after every ship |

### Quality & Safety

| Skill | Role | What it does |
|-------|------|--------------|
| `/debug` | Root Cause Analysis | Four-phase: investigate → pattern → hypothesis → fix. No guessing. |
| `/verify` | Evidence Gate | No claiming "done" without terminal output as proof |
| `/respond` | Review Reception | Evaluate feedback technically before implementing. Push back when wrong. |

### Execution

| Skill | Role | What it does |
|-------|------|--------------|
| `/delegate` | Subagent Execution | Sequential (plan task-by-task with two-stage review) or parallel (independent problems) |
| `/retro` | Weekly Retrospective | What shipped, contributor breakdown, streak, one action item |

## Install

```bash
git clone https://github.com/zmzhace/fullstack-skills.git ~/.claude/skills/forge
```

Add to your project's `CLAUDE.md`:

```markdown
## Forge Skills
Available: /think, /plan, /build, /review, /ship, /sync, /debug, /verify, /respond, /delegate, /retro
```

## Quick Start

```
/think      ← describe what you want to build
/plan       ← architecture + tasks from your spec
/build      ← TDD implementation, task by task
/review     ← production bugs + security + plan compliance
/ship       ← verify, push, open PR
/sync       ← update docs to match what shipped
```

Hit a bug during `/build`? Run `/debug` first, then `/verify` before claiming it's fixed.
Received PR feedback? Use `/respond` to evaluate it before making changes.
Multiple independent tasks? Use `/delegate` to run them in parallel with review gates.

## Design Principles

1. **Evidence before assertions** — `/verify` and `/ship` require real terminal output, not claims
2. **Root cause over symptoms** — `/debug` enforces four phases before any fix
3. **No auto-fix** — `/review` presents all findings for human decision; nothing changed silently
4. **Sequential but not mandatory** — any skill runs standalone; only `/ship` hard-blocks on test failure
5. **Self-correcting** — `/think` and `/plan` both include self-review before handoff

## License

MIT
