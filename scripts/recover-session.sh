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

echo "closing session if it exists: $ACPX_SESSION"
"$ACPX_BIN" --cwd "$WORKDIR" "$CLAUDE_ACPX_AGENT" sessions close "$ACPX_SESSION" >/dev/null 2>&1 || true

echo "re-ensuring session"
"$ACPX_BIN" --cwd "$WORKDIR" --timeout "$ACPX_TIMEOUT" "$CLAUDE_ACPX_AGENT" sessions ensure --name "$ACPX_SESSION"

echo
echo "run the smoke test again:"
echo "  ./scripts/dispatch-task.sh examples/first-task.md $ACPX_SESSION"
