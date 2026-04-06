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

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { printf "${GREEN}  ✓  %s${NC}\n" "$1"; }
fail() { printf "${RED}  ✗  %s${NC}\n" "$1"; }
warn() { printf "${YELLOW}  ⚠  %s${NC}\n" "$1"; }
info() { printf "     %s\n" "$1"; }

need() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1 found: $(command -v "$1")"
  else
    fail "$1 not found"
    shift
    for msg in "$@"; do
      info "$msg"
    done
    exit 1
  fi
}

printf "\n${BOLD}── checking required binaries ───────────────────────────────────${NC}\n\n"

need "$OPENCLAW_BIN" \
  "openclaw is not installed or not in your PATH." \
  "Install it from https://openclaw.dev and open a new terminal."

need "$CLAUDE_BIN" \
  "claude code is not installed or not in your PATH." \
  "Install it with the native binary installer (no Node.js required):" \
  "  Mac / Linux:  curl -fsSL https://claude.ai/install.sh | bash" \
  "  Windows:      irm https://claude.ai/install.ps1 | iex" \
  "Then open a new terminal and run this again."

if command -v "$ACPX_BIN" >/dev/null 2>&1; then
  ok "acpx found: $(command -v "$ACPX_BIN")"
else
  warn "acpx not found in PATH"
  info "acpx is usually bundled with openclaw."
  info "Run /acp doctor inside openclaw's chat to repair the path."
fi

printf "\n${BOLD}── versions ─────────────────────────────────────────────────────${NC}\n\n"

"$OPENCLAW_BIN" --version 2>/dev/null && true
"$CLAUDE_BIN" --version 2>/dev/null && true
command -v "$ACPX_BIN" >/dev/null 2>&1 && "$ACPX_BIN" --version 2>/dev/null && true

printf "\n${BOLD}── claude auth status ───────────────────────────────────────────${NC}\n\n"

if "$CLAUDE_BIN" auth status --text; then
  ok "claude is logged in"
else
  fail "claude is not logged in"
  info "Run this command and follow the browser prompt:"
  info "  claude auth login"
  info "Then run this preflight again."
  exit 1
fi

printf "\n${BOLD}── openclaw model status ────────────────────────────────────────${NC}\n\n"

"$OPENCLAW_BIN" models status 2>/dev/null || warn "Could not get openclaw model status — openclaw may not be running yet."

printf "\n${BOLD}── working directory ────────────────────────────────────────────${NC}\n\n"

if [[ -n "$WORKDIR" && "$WORKDIR" != "$PWD" ]]; then
  if [[ -d "$WORKDIR" ]]; then
    ok "WORKDIR exists: $WORKDIR"
  else
    fail "WORKDIR does not exist: $WORKDIR"
    info "Check the WORKDIR value in your .env file."
    info "It must be the full path to a directory that already exists."
    exit 1
  fi
else
  warn "WORKDIR is not set in .env — defaulting to current directory"
  info "Set WORKDIR in .env to the full path of the repo you want claude to work in."
fi

printf "\n${BOLD}── next steps ───────────────────────────────────────────────────${NC}\n\n"
printf "  1.  If you have not already: bash scripts/login-openclaw-anthropic-cli.sh\n"
printf "  2.  Run /acp doctor inside openclaw chat\n"
printf "  3.  Run /acp spawn claude --bind here in your target conversation\n"
printf "  4.  Run: bash scripts/smoke-test.sh\n\n"
