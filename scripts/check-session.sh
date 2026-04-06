#!/usr/bin/env bash
set -euo pipefail

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
fi

ACPX_BIN="${ACPX_BIN:-acpx}"
CLAUDE_ACPX_AGENT="${CLAUDE_ACPX_AGENT:-claude}"
ACPX_SESSION="${ACPX_SESSION:-bridge-main}"
WORKDIR="${WORKDIR:-$PWD}"

command -v "$ACPX_BIN" >/dev/null 2>&1 || {
  echo "missing acpx"
  exit 1
}

echo "status"
"$ACPX_BIN" --cwd "$WORKDIR" "$CLAUDE_ACPX_AGENT" status || true

echo
echo "sessions"
"$ACPX_BIN" --cwd "$WORKDIR" "$CLAUDE_ACPX_AGENT" sessions list || true

echo
echo "recent history"
"$ACPX_BIN" --cwd "$WORKDIR" "$CLAUDE_ACPX_AGENT" sessions history --limit 5 || true

echo
echo "target session"
echo "$ACPX_SESSION"
