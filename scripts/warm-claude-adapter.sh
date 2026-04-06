#!/usr/bin/env bash
set -euo pipefail

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
fi

ACPX_BIN="${ACPX_BIN:-acpx}"
CLAUDE_ACPX_AGENT="${CLAUDE_ACPX_AGENT:-claude}"
ACPX_SESSION="${ACPX_SESSION:-bridge-main}"
ACPX_TIMEOUT="${ACPX_TIMEOUT:-1800}"
WORKDIR="${WORKDIR:-$PWD}"

command -v "$ACPX_BIN" >/dev/null 2>&1 || {
  echo "missing acpx"
  exit 1
}

echo "ensuring session: $ACPX_SESSION"
"$ACPX_BIN" --cwd "$WORKDIR" --timeout "$ACPX_TIMEOUT" "$CLAUDE_ACPX_AGENT" sessions ensure --name "$ACPX_SESSION"

echo
echo "warming the adapter with a tiny prompt"
"$ACPX_BIN" --cwd "$WORKDIR" --timeout "$ACPX_TIMEOUT" --format quiet "$CLAUDE_ACPX_AGENT" -s "$ACPX_SESSION" "reply with exactly acpx-claude-warm-ok"
