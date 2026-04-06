#!/usr/bin/env bash
set -euo pipefail

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
fi

OPENCLAW_BIN="${OPENCLAW_BIN:-openclaw}"

echo 'openclaw acp doctor'
if command -v "$OPENCLAW_BIN" >/dev/null 2>&1; then
  "$OPENCLAW_BIN" acp doctor || true
else
  echo 'missing openclaw'
fi

echo
echo 'inside your openclaw chat surface'
echo '  /acp doctor'
echo '  /acp spawn claude --bind here'
