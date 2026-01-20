#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create symlinks for moonbit-agent-guide skills
ln -sfn "$SCRIPT_DIR/moonbit-agent-guide-src/moonbit-agent-guide" "$SCRIPT_DIR/moonbit-agent-guide"
ln -sfn "$SCRIPT_DIR/moonbit-agent-guide-src/moonbit-refactoring" "$SCRIPT_DIR/moonbit-refactoring"

echo "Created symlinks:"
echo "  moonbit-agent-guide -> moonbit-agent-guide-src/moonbit-agent-guide"
echo "  moonbit-refactoring -> moonbit-agent-guide-src/moonbit-refactoring"
