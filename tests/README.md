# Forge Skill Tests

Tests that verify skills trigger correctly and agents follow the right process.

## Structure

```
tests/
  trigger/          — test that each skill is invoked when it should be
  prompts/          — scenario prompts used by trigger tests
  run-all.sh        — run all tests
  run-test.sh       — run a single test
```

## Running Tests

```bash
# Run all trigger tests
./tests/run-all.sh

# Run a specific skill's trigger test
./tests/run-test.sh build

# Run with a specific model
./tests/run-test.sh debug --model claude-opus-4-6
```

## What Each Test Does

Each trigger test sends a prompt to Claude and checks whether the agent loaded the expected skill. A test passes if the agent's response indicates the skill was used (either by announcing it or by following its process).

## Adding a New Test

1. Add a prompt file to `tests/prompts/<skill-name>.txt`
2. Add the skill name to the list in `run-all.sh`

The prompt should describe a scenario that clearly calls for that skill — not just any scenario, but one where skipping the skill would be an error.
