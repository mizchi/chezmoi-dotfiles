#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# moonbit-agent-guide skills
ln -sfn "$SCRIPT_DIR/moonbit-agent-guide-src/moonbit-agent-guide" "$SCRIPT_DIR/moonbit-agent-guide"
ln -sfn "$SCRIPT_DIR/moonbit-agent-guide-src/moonbit-refactoring" "$SCRIPT_DIR/moonbit-refactoring"

# moonbit-practice (from ghq)
ln -sfn "$HOME/ghq/github.com/mizchi/moonbit-practice/skills/moonbit-practice" "$SCRIPT_DIR/moonbit-practice"

echo "Created symlinks:"
echo "  moonbit-agent-guide -> moonbit-agent-guide-src/moonbit-agent-guide"
echo "  moonbit-refactoring -> moonbit-agent-guide-src/moonbit-refactoring"
echo "  moonbit-practice -> ~/ghq/github.com/mizchi/moonbit-practice/skills/moonbit-practice"
