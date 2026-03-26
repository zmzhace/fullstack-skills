#!/usr/bin/env bash
# Run all Forge skill trigger tests.
# Usage: ./tests/run-all.sh [--model <model-id>]

set -euo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL="${2:-claude-sonnet-4-6}"

SKILLS=(
  think
  plan
  build
  review
  ship
  sync
  debug
  verify
  respond
  delegate
  worktree
  retro
  write-skill
)

PASS=0
FAIL=0
SKIP=0

for skill in "${SKILLS[@]}"; do
  PROMPT_FILE="$TESTS_DIR/prompts/${skill}.txt"
  if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "⏭  SKIP: $skill (no prompt file at prompts/${skill}.txt)"
    ((SKIP++)) || true
    continue
  fi

  if "$TESTS_DIR/run-test.sh" "$skill" --model "$MODEL"; then
    ((PASS++)) || true
  else
    ((FAIL++)) || true
  fi
  echo ""
done

echo "=============================="
echo "Results: $PASS passed, $FAIL failed, $SKIP skipped"
echo "=============================="

[[ $FAIL -eq 0 ]]
