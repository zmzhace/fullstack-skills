#!/usr/bin/env bash
# Run a single Forge skill trigger test.
# Usage: ./tests/run-test.sh <skill-name> [--model <model-id>]

set -euo pipefail

SKILL="${1:-}"
MODEL="${3:-claude-sonnet-4-6}"
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$TESTS_DIR")"
PROMPT_FILE="$TESTS_DIR/prompts/${SKILL}.txt"

if [[ -z "$SKILL" ]]; then
  echo "Usage: $0 <skill-name> [--model <model-id>]"
  exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "ERROR: No prompt file at $PROMPT_FILE"
  exit 1
fi

echo "=== Testing skill: $SKILL ==="
echo "--- Prompt ---"
cat "$PROMPT_FILE"
echo ""
echo "--- Running ---"

# Run the prompt through Claude and check for skill usage signals
RESPONSE=$(claude --model "$MODEL" --print < "$PROMPT_FILE" 2>&1)

echo "--- Response (first 400 chars) ---"
echo "${RESPONSE:0:400}"
echo ""

# Check for skill invocation signals in the response
SKILL_SIGNALS=(
  "/$SKILL"
  "using the $SKILL skill"
  "Using $SKILL"
  "I'm using $SKILL"
)

FOUND=0
for signal in "${SKILL_SIGNALS[@]}"; do
  if echo "$RESPONSE" | grep -qi "$signal"; then
    FOUND=1
    break
  fi
done

if [[ $FOUND -eq 1 ]]; then
  echo "✅ PASS: skill '$SKILL' was triggered"
  exit 0
else
  echo "❌ FAIL: skill '$SKILL' was NOT triggered"
  echo "--- Full response ---"
  echo "$RESPONSE"
  exit 1
fi
