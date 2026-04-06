#!/usr/bin/env bash
set -euo pipefail

# always run from repo root so relative paths work correctly
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

ACPX_SESSION="${ACPX_SESSION:-bridge-main}"
OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

printf "\n${BOLD}── smoke test ───────────────────────────────────────────────────${NC}\n"
printf "\n  Sending prompt: 'reply with exactly live-acp-claude-ok'\n"
printf "  Expected back:  live-acp-claude-ok\n\n"

if ! bash scripts/dispatch-task.sh examples/tasks/smoke-test.md "$ACPX_SESSION" | tee "$OUT"; then
  printf "\n${RED}  ✗  Dispatch failed — the task could not be sent.${NC}\n"
  printf "     Most likely causes:\n"
  printf "     • acpx is not installed or not in PATH\n"
  printf "     • the session '%s' does not exist yet\n" "$ACPX_SESSION"
  printf "     • openclaw is not running\n"
  printf "     Fix: run /acp spawn claude --bind here in openclaw chat, then try again.\n\n"
  exit 1
fi

if grep -q 'live-acp-claude-ok' "$OUT"; then
  printf "\n${GREEN}${BOLD}  ✓  SMOKE TEST PASSED${NC}\n"
  printf "${GREEN}     The full bridge is live and working.${NC}\n\n"
  printf "  What this confirms:\n"
  printf "  • claude auth is valid on this host\n"
  printf "  • the acpx session is live\n"
  printf "  • messages can reach claude code through openclaw\n\n"
  printf "  What to test next:\n"
  printf "  • bash scripts/dispatch-task.sh examples/tasks/repo-fix.md\n\n"
  exit 0
else
  printf "\n${RED}${BOLD}  ✗  SMOKE TEST FAILED${NC}\n"
  printf "${RED}     The bridge did not return the expected token.${NC}\n\n"
  printf "  What to check:\n"
  printf "  1.  Did you run /acp spawn claude --bind here in your openclaw conversation?\n"
  printf "      That step is required before the smoke test will work.\n\n"
  printf "  2.  Is openclaw running and connected?\n"
  printf "      Try /acp doctor inside the openclaw chat surface.\n\n"
  printf "  3.  Did you restart openclaw after editing the config?\n"
  printf "      Config changes only take effect after a restart.\n\n"
  printf "  4.  Is the acpx session stale?\n"
  printf "      Run: bash scripts/recover-session.sh\n"
  printf "      Then try the smoke test again.\n\n"
  printf "  5.  Check claude auth:\n"
  printf "      Run: claude auth status --text\n\n"
  exit 1
fi
