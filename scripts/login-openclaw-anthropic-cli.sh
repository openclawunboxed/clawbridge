#!/usr/bin/env bash
set -euo pipefail

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
fi

OPENCLAW_BIN="${OPENCLAW_BIN:-openclaw}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"

echo "step 1: verify claude auth on this host"
"$CLAUDE_BIN" auth status --text || {
  echo "claude is not logged in on this host"
  echo "run: claude auth login"
  exit 1
}

echo
echo "step 2: tell openclaw to reuse the local claude cli login for anthropic"
"$OPENCLAW_BIN" models auth login --provider anthropic --method cli --set-default

echo
echo "done"
echo "openclaw should now prefer the local claude cli reuse path for anthropic-backed runs on this host"
