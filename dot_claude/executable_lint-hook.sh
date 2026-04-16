#!/bin/bash
# Global Claude Code PostToolUse lint hook.
# Reads JSON from stdin, detects the project root and available linters,
# then runs the appropriate linter for the edited file type.

input=$(cat)
f=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$f" ] && exit 0

# Resolve project root from the edited file's location
dir=$(dirname "$f")
root=$(cd "$dir" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)
[ -z "$root" ] && exit 0

cd "$root"

if echo "$f" | grep -qE '\.py$'; then
  if [ -f "pyproject.toml" ] || [ -f "ruff.toml" ]; then
    uv run ruff check . 2>&1 | tail -10
  fi
  if grep -q "\[tool\.mypy\]" pyproject.toml 2>/dev/null; then
    uv run mypy . 2>&1 | tail -10
  fi
elif echo "$f" | grep -qE '\.js$'; then
  if [ -f "eslint.config.js" ] || ls .eslintrc* 2>/dev/null | grep -q .; then
    npm run lint --silent 2>&1 | tail -10
  fi
fi
