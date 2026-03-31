#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UPDATE=false
if [[ "${1:-}" == "--update" ]]; then
  UPDATE=true
fi

# --- Prerequisites check ---
missing=()
command -v npx >/dev/null 2>&1 || missing+=("npx (Node.js)")
command -v ghq >/dev/null 2>&1 || missing+=("ghq")

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Error: missing required commands:" >&2
  for cmd in "${missing[@]}"; do
    echo "  - $cmd" >&2
  done
  exit 1
fi

MOONBIT_PRACTICE_REPO="$HOME/ghq/github.com/mizchi/moonbit-practice"
if [[ ! -d "$MOONBIT_PRACTICE_REPO" ]]; then
  echo "Cloning mizchi/moonbit-practice via ghq..."
  ghq get mizchi/moonbit-practice
elif [[ "$UPDATE" == true ]]; then
  echo "Updating mizchi/moonbit-practice via ghq..."
  ghq get -u mizchi/moonbit-practice
fi

# --- moonbit-agent-guide / moonbit-refactoring (fetch with tiged) ---
fetch_tiged() {
  local repo="$1" dest="$2"
  if [[ "$UPDATE" == true && -d "$dest" ]]; then
    echo "Updating $(basename "$dest")..."
    rm -rf "$dest"
  fi
  if [[ ! -d "$dest" ]]; then
    npx tiged "$repo" "$dest"
  else
    echo "  $(basename "$dest") already exists (use --update to re-fetch)"
  fi
}

fetch_tiged "moonbitlang/moonbit-agent-guide/moonbit-agent-guide" "$SCRIPT_DIR/moonbit-agent-guide"
fetch_tiged "moonbitlang/moonbit-agent-guide/moonbit-refactoring" "$SCRIPT_DIR/moonbit-refactoring"
fetch_tiged "moonbitlang/moonbit-agent-guide/moonbit-c-binding" "$SCRIPT_DIR/moonbit-c-binding"


# --- moonbit-practice (symlink from ghq) ---
# Remove existing dir/symlink first to avoid ln creating a link inside it
if [[ -e "$SCRIPT_DIR/moonbit-practice" || -L "$SCRIPT_DIR/moonbit-practice" ]]; then
  rm -rf "$SCRIPT_DIR/moonbit-practice"
fi
ln -sfn "$MOONBIT_PRACTICE_REPO/skills/moonbit-practice" "$SCRIPT_DIR/moonbit-practice"

echo "Setup complete:"
echo "  moonbit-agent-guide (tiged)"
echo "  moonbit-refactoring (tiged)"
echo "  moonbit-practice -> $MOONBIT_PRACTICE_REPO/skills/moonbit-practice"
