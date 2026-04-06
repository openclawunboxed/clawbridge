#!/usr/bin/env bash
set -euo pipefail

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
fi

OPENCLAW_BIN="${OPENCLAW_BIN:-openclaw}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
ACPX_BIN="${ACPX_BIN:-acpx}"
WORKDIR="${WORKDIR:-$PWD}"
OUTDIR="$WORKDIR/proof"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTDIR"

{
  echo "timestamp=$STAMP"
  echo
  echo '== versions =='
  command -v "$OPENCLAW_BIN" >/dev/null 2>&1 && "$OPENCLAW_BIN" --version || echo 'openclaw=missing'
  command -v "$CLAUDE_BIN" >/dev/null 2>&1 && "$CLAUDE_BIN" --version || echo 'claude=missing'
  command -v "$ACPX_BIN" >/dev/null 2>&1 && "$ACPX_BIN" --version || echo 'acpx=missing'
  echo
  echo '== auth =='
  command -v "$CLAUDE_BIN" >/dev/null 2>&1 && "$CLAUDE_BIN" auth status --text || true
  command -v "$OPENCLAW_BIN" >/dev/null 2>&1 && "$OPENCLAW_BIN" models status || true
  echo
  echo '== session status =='
  ./scripts/check-session.sh || true
} > "$OUTDIR/bridge-proof-$STAMP.txt"

echo "wrote $OUTDIR/bridge-proof-$STAMP.txt"
