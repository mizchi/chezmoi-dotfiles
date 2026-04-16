#!/bin/bash
# Install APM-managed skills after chezmoi apply
set -eu

if ! command -v apm >/dev/null 2>&1; then
  echo "[chezmoi] apm not found, skipping skill installation"
  exit 0
fi

echo "[chezmoi] Running apm install -g ..."
apm install --global --target claude 2>&1 | tail -5
