#!/usr/bin/env sh
# Bootstrap step: clone Homebrew to ~/brew if missing.
# Single-user install (no sudo needed). Runs once per machine via chezmoi.
# nix-darwin's homebrew module references this prefix at activation time,
# so brew must be present BEFORE the first `darwin-rebuild switch`.
set -eu

if [ -x "$HOME/brew/bin/brew" ]; then
  exit 0
fi

echo "[chezmoi] Cloning Homebrew (single-user) into $HOME/brew ..."
git clone --depth=1 https://github.com/Homebrew/brew "$HOME/brew"
"$HOME/brew/bin/brew" --version
