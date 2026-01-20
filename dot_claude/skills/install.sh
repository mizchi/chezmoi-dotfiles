#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# moonbit-agent-guide (fetch with tiged)
if [[ ! -d "$SCRIPT_DIR/moonbit-agent-guide" ]]; then
  npx tiged moonbitlang/moonbit-agent-guide/moonbit-agent-guide "$SCRIPT_DIR/moonbit-agent-guide"
fi
if [[ ! -d "$SCRIPT_DIR/moonbit-refactoring" ]]; then
  npx tiged moonbitlang/moonbit-agent-guide/moonbit-refactoring "$SCRIPT_DIR/moonbit-refactoring"
fi

# moonbit-practice (from ghq)
ln -sfn "$HOME/ghq/github.com/mizchi/moonbit-practice/skills/moonbit-practice" "$SCRIPT_DIR/moonbit-practice"

echo "Setup complete:"
echo "  moonbit-agent-guide (tiged)"
echo "  moonbit-refactoring (tiged)"
echo "  moonbit-practice -> ~/ghq/github.com/mizchi/moonbit-practice/skills/moonbit-practice"
