# Forge

Thirteen skills for a complete software development workflow — from idea to shipped, maintained, and retrospected.

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
| `/delegate` | Subagent Execution | Sequential / inline / parallel execution with role injection and model selection |
| `/worktree` | Isolated Workspace | Create, setup, and validate git worktrees for parallel development |
| `/retro` | Weekly Retrospective | What shipped, contributor breakdown, streak, one action item |
| `/write-skill` | Skill Authoring | TDD for documentation — baseline test, minimal skill, bulletproofing |

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

## Why This Works

Research on LLM agents shows a counterintuitive result: **imposing rigorous process on an existing model produces better outcomes than letting a more capable model work undisciplined**. Forge is built on this insight.

The core mechanism is enforcement *before* response. Skills are checked before any action — including clarifying questions. This prevents the most common failure mode: an agent that rationalizes skipping process under pressure ("this is a simple case," "there's no time for tests"). The rationalization happens after the decision; checking skills first short-circuits it.

Each skill includes a **rationalization table** — a list of thoughts that signal you're about to skip something important. These are the exact justifications that cause failures in production. Naming them makes them visible.

The subagent system applies the same principle at the team level: fresh agents don't inherit biases from the session that created the problem. Two-stage review (spec compliance → code quality) separates concerns that cross-contaminate when done by the same reviewer.

## Platform Support

Forge is written for Claude Code. For Cursor, Gemini CLI, OpenCode, and Codex — see [`references/platform-guide.md`](references/platform-guide.md) for tool name mappings and installation instructions.

## License

MIT
