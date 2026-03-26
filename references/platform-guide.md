# Forge Platform Guide

Forge skills are written for Claude Code. If you use a different platform, this guide maps the tool names and invocation patterns to their equivalents.

## Tool Name Mapping

| Claude Code | Cursor | Gemini CLI | OpenCode | Codex |
|-------------|--------|-----------|----------|-------|
| `Skill` tool | `/skill-name` command | `activate_skill` tool | `@forge/<skill>` | `/skill-name` |
| `Agent` tool | Inline agent | `spawn_agent` | `@agent` | agent block |
| `TodoWrite` | `<todo>` block | `todo_write` | `@todo` | todo block |
| `Bash` | Terminal | `run_command` | `@bash` | bash block |
| `Read` | File read | `read_file` | `@read` | read block |
| `Edit` | File edit | `edit_file` | `@edit` | edit block |
| `Write` | File write | `write_file` | `@write` | write block |
| `Glob` | File search | `glob` | `@glob` | glob block |
| `Grep` | Code search | `grep` | `@grep` | grep block |

## Platform-Specific Installation

### Claude Code

```bash
git clone https://github.com/zmzhace/fullstack-skills.git ~/.claude/skills/forge
```

Add to your project's `CLAUDE.md`:
```markdown
## Forge Skills
Available: /think, /plan, /build, /review, /ship, /sync, /debug, /verify, /respond, /delegate, /retro, /worktree, /write-skill
```

Invoke with the `Skill` tool: `skill: "think"` or type `/think` in chat.

### Cursor

```bash
git clone https://github.com/zmzhace/fullstack-skills.git ~/.cursor/skills/forge
```

Invoke skills via `/skill-name` in the chat panel. Agent dispatch uses inline agent blocks.

### Gemini CLI

```bash
gemini extensions install https://github.com/zmzhace/fullstack-skills
```

Skills activate via `activate_skill`. The tool mapping is loaded automatically from `references/codex-tools.md` if present.

### OpenCode

Skills integrate via OpenCode's hook-based extension system. Reference skills using `@forge/<skill-name>` in your prompts.

### Codex / Other

For platforms not listed: skills are plain markdown files. Copy the content of any `SKILL.md` directly into your system prompt or as a user message prefix. The process flows and constraints work regardless of how they are loaded.

## Behavioral Differences by Platform

Some skill behaviors require platform-specific adaptation:

| Behavior | Claude Code | Other platforms |
|----------|-------------|-----------------|
| Skill invocation | `Skill` tool (structured) | Text command or copy-paste |
| Subagent dispatch | `Agent` tool with `model:` param | Platform-specific agent API |
| Model selection | `model: "haiku"/"sonnet"/"opus"` | Platform model names vary |
| Task tracking | `TaskCreate`/`TaskUpdate` | Use a TODO comment block |
| Plan mode | `EnterPlanMode` | Describe plan in text |

## Model Name Reference

When dispatching subagents, use these model IDs:

| Tier | Claude Code shorthand | Full model ID |
|------|-----------------------|---------------|
| Fast / cheap | `haiku` | `claude-haiku-4-5-20251001` |
| Balanced | `sonnet` | `claude-sonnet-4-6` |
| Powerful | `opus` | `claude-opus-4-6` |

Non-Claude platforms: use the equivalent model tier for your provider. The principle is the same — match model capability to task complexity.
