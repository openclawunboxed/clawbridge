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
ACPX_PERMISSIONS="${ACPX_PERMISSIONS:-approve-all}"
ACPX_NON_INTERACTIVE="${ACPX_NON_INTERACTIVE:-fail}"
WORKDIR="${WORKDIR:-$PWD}"

[[ $# -ge 1 ]] || {
  echo "usage: $0 <prompt-file> [session-name]"
  exit 1
}
PROMPT_FILE="$1"
SESSION_NAME="${2:-$ACPX_SESSION}"
[[ -f "$PROMPT_FILE" ]] || {
  echo "prompt file not found: $PROMPT_FILE"
  exit 1
}

case "$ACPX_PERMISSIONS" in
  approve-all) PERM_FLAG=(--approve-all) ;;
  approve-reads) PERM_FLAG=(--approve-reads) ;;
  deny-all) PERM_FLAG=(--deny-all) ;;
  *)
    echo "unsupported ACPX_PERMISSIONS value: $ACPX_PERMISSIONS"
    exit 1
    ;;
esac

command -v "$ACPX_BIN" >/dev/null 2>&1 || {
  echo "missing acpx"
  exit 1
}

"$ACPX_BIN" --cwd "$WORKDIR" --timeout "$ACPX_TIMEOUT" "$CLAUDE_ACPX_AGENT" sessions ensure --name "$SESSION_NAME" >/dev/null

"$ACPX_BIN" \
  --cwd "$WORKDIR" \
  --timeout "$ACPX_TIMEOUT" \
  --format json \
  --json-strict \
  --non-interactive-permissions "$ACPX_NON_INTERACTIVE" \
  "${PERM_FLAG[@]}" \
  "$CLAUDE_ACPX_AGENT" \
  -s "$SESSION_NAME" \
  --file "$PROMPT_FILE"
