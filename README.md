# fullstack-skills

Five Claude Code skills for a complete sprint workflow — from idea to shipped PR.

```
/think → /plan → /build → /review → /ship
```

## What It Is

| Skill | Role | What it does |
|-------|------|-------------|
| `/think` | Product Thinking | Challenges your framing, extracts real pain, writes a spec |
| `/plan` | Architecture + Tasks | ASCII diagrams, edge cases, TDD-ready task breakdown |
| `/build` | TDD Implementation | Red → Green → Commit, hard gate on application logic |
| `/review` | Quality Gate | Production bugs + OWASP/STRIDE security + plan compliance |
| `/ship` | Verified Release | Tests must pass before PR opens — no exceptions |

## Install

```bash
git clone https://github.com/zmzhace/fullstack-skills.git ~/.claude/skills/fullstack-skills
```

Add to your project's `CLAUDE.md`:

```markdown
## fullstack-skills
Available skills: /think, /plan, /build, /review, /ship
```

## Quick Start

```
/think    ← describe what you want to build
/plan     ← architecture + tasks from your spec
/build    ← TDD implementation
/review   ← production bugs + security + plan compliance
/ship     ← verify, push, open PR
```

See [docs/workflow.md](docs/workflow.md) for a full example.

## Design Principles

1. **Evidence before assertions** — no claiming done without showing real output
2. **Adversarial by default** — each skill finds problems, not validates existing work
3. **Sequential but not mandatory** — run any skill standalone; only `/ship` hard-blocks on test failure
4. **Self-contained** — no external dependencies

## License

MIT
