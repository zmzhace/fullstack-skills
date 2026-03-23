#!/usr/bin/env bash
# Validates all SKILL.md files have required frontmatter and sections
set -e

ERRORS=0

for skill in think plan build review ship; do
  FILE="skills/$skill/SKILL.md"
  if [ ! -f "$FILE" ]; then
    echo "MISSING: $FILE"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Check frontmatter exists
  if ! head -1 "$FILE" | grep -q "^---$"; then
    echo "NO FRONTMATTER: $FILE"
    ERRORS=$((ERRORS + 1))
  fi

  # Check name field
  if ! grep -q "^name:" "$FILE"; then
    echo "MISSING name: $FILE"
    ERRORS=$((ERRORS + 1))
  fi

  # Check description field
  if ! grep -q "^description:" "$FILE"; then
    echo "MISSING description: $FILE"
    ERRORS=$((ERRORS + 1))
  fi

  # Check no TODOs
  if grep -qi "TODO\|PLACEHOLDER\|FIXME" "$FILE"; then
    echo "HAS PLACEHOLDER: $FILE"
    ERRORS=$((ERRORS + 1))
  fi

  echo "OK: $FILE"
done

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "FAILED: $ERRORS error(s)"
  exit 1
else
  echo ""
  echo "All skills valid."
fi
