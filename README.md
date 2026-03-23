# fullstack-skills

Five Claude Code skills that combine the best of [superpowers](https://github.com/obra/superpowers) and [gstack](https://github.com/garrytan/gstack) into a unified, self-contained sprint workflow.

```
/think → /plan → /build → /review → /ship
```

No dependency on superpowers or gstack being installed.

## What It Is

| Skill | Role | Combines |
|-------|------|---------|
| `/think` | Product Thinking | gstack `/office-hours` + superpowers `brainstorming` |
| `/plan` | Architecture + Tasks | gstack `/plan-eng-review` + superpowers `writing-plans` |
| `/build` | TDD Implementation | superpowers `test-driven-development` + gstack quality |
| `/review` | Quality Gate | gstack `/review` + gstack `/cso` + superpowers `requesting-code-review` |
| `/ship` | Verified Release | superpowers `verification-before-completion` + gstack `/ship` |

## Install

```bash
git clone https://github.com/your-username/fullstack-skills.git ~/.claude/skills/fullstack-skills
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
