#!/usr/bin/env bash
# setup-guided.sh
# Interactive step-by-step setup wizard for clawbridge-acp.
# Safe to run more than once — every step checks before acting.

set -uo pipefail

# ── formatting ────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

sep()   { printf "\n${BLUE}${BOLD}════════════════════════════════════════${NC}\n"; }
step()  { sep; printf "${BLUE}${BOLD} STEP %s: %s${NC}\n" "$1" "$2"; }
ok()    { printf "${GREEN}  ✓  %s${NC}\n" "$1"; }
fail()  { printf "${RED}  ✗  %s${NC}\n" "$1"; }
warn()  { printf "${YELLOW}  ⚠  %s${NC}\n" "$1"; }
info()  { printf "     %s\n" "$1"; }
blank() { printf "\n"; }

abort() {
  blank; fail "Setup stopped: $1"
  info "Fix the issue above, then re-run: bash scripts/setup-guided.sh"
  blank; exit 1
}

# ── repo root guard ───────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [[ ! -f "scripts/setup-guided.sh" ]]; then
  fail "Cannot find scripts/setup-guided.sh from: $REPO_ROOT"
  info "Run this script from inside the clawbridge-acp repo."
  exit 1
fi

[[ -f .env ]] && source .env

OPENCLAW_BIN="${OPENCLAW_BIN:-openclaw}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
ACPX_BIN="${ACPX_BIN:-acpx}"

# ── OS detection ──────────────────────────────────────────────────────────────
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
elif grep -qi microsoft /proc/version 2>/dev/null; then
  OS="wsl"
elif [[ "$OSTYPE" == "linux"* ]]; then
  OS="linux"
fi

# ── intro ─────────────────────────────────────────────────────────────────────
clear
printf "${BOLD}"
printf "  clawbridge-acp  —  guided setup wizard\n"
printf "  ───────────────────────────────────────\n"
printf "${NC}"
printf "  This wizard walks through every step in order.\n"
printf "  Every step checks before acting — safe to re-run.\n"
[[ "$OS" != "unknown" ]] && printf "  Detected platform: %s\n" "$OS"
blank
printf "  Press Enter to start..."; read -r

# ── step 1: check binaries ────────────────────────────────────────────────────
step 1 "Checking required tools"

MISSING=0

if command -v "$OPENCLAW_BIN" >/dev/null 2>&1; then
  ok "openclaw found: $(command -v "$OPENCLAW_BIN")"
else
  fail "openclaw not found"
  info "Install openclaw following their official documentation."
  info "After installing, open a new terminal and run this wizard again."
  MISSING=1
fi

if command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
  ok "claude found: $(command -v "$CLAUDE_BIN")"
else
  fail "claude code not found"
  info "Install with the native binary installer (no Node.js required):"
  info "  Mac / Linux:  curl -fsSL https://claude.ai/install.sh | bash"
  info "  Windows:      irm https://claude.ai/install.ps1 | iex"
  if [[ "$OS" == "wsl" ]]; then
    info "  WSL users: run the Mac/Linux command inside your WSL terminal."
  fi
  info "After installing, open a new terminal and run this wizard again."
  MISSING=1
fi

PYTHON3_OK=0
if command -v python3 >/dev/null 2>&1; then
  ok "python3 found: $(command -v python3)"
  PYTHON3_OK=1
else
  warn "python3 not found — config merge will use manual mode"
  info "Install from https://python.org or via your system package manager."
fi

if command -v "$ACPX_BIN" >/dev/null 2>&1; then
  ok "acpx found: $(command -v "$ACPX_BIN")"
else
  warn "acpx not found in PATH"
  info "acpx is usually bundled with openclaw."
  info "Run /acp doctor inside openclaw chat to repair the path after setup."
fi

[[ $MISSING -eq 1 ]] && abort "Required tools are missing (see above)."

# ── step 2: claude auth ───────────────────────────────────────────────────────
step 2 "Checking claude auth"

if "$CLAUDE_BIN" auth status --text >/dev/null 2>&1; then
  AUTH_DETAIL="$("$CLAUDE_BIN" auth status --text 2>&1 || true)"
  ok "claude is logged in"
  info "$AUTH_DETAIL"
else
  fail "claude is not logged in"
  info "Run this and follow the browser prompt:"
  info "  claude auth login"
  info "Then run this wizard again."
  abort "claude auth login required"
fi

# ── step 3: .env ──────────────────────────────────────────────────────────────
step 3 "Setting up .env"

if [[ -f .env ]]; then
  ok ".env already exists — skipping"
else
  cp .env.example .env
  ok "Created .env from .env.example"
fi

# ── step 4: global acpx config ────────────────────────────────────────────────
step 4 "Copying global acpx config"

ACPX_CONFIG_DIR="$HOME/.acpx"
ACPX_CONFIG_FILE="$ACPX_CONFIG_DIR/config.json"

if [[ -f "$ACPX_CONFIG_FILE" ]]; then
  ok "$ACPX_CONFIG_FILE already exists — skipping"
else
  mkdir -p "$ACPX_CONFIG_DIR"
  cp configs/acpx.global.config.json.example "$ACPX_CONFIG_FILE"
  ok "Copied to $ACPX_CONFIG_FILE"
fi

# ── step 5: repo path ─────────────────────────────────────────────────────────
step 5 "Setting your working repo path"

blank
info "This is the folder where claude code will do its work."
info "It must already exist. Use the full absolute path."
blank
if [[ "$OS" == "mac" ]]; then
  info "Tip: drag the folder into this terminal window to paste its full path."
elif [[ "$OS" == "wsl" ]]; then
  info "Use the Linux-style path, e.g. /home/yourname/myproject"
  info "Not the Windows path like C:\\Users\\..."
fi
blank
printf "${BOLD}  Enter the full path to your repo: ${NC}"
read -r USER_REPO_PATH

if [[ -z "$USER_REPO_PATH" ]]; then
  abort "No path entered."
fi

# Expand ~ if user typed it
USER_REPO_PATH="${USER_REPO_PATH/#\~/$HOME}"

if [[ ! -d "$USER_REPO_PATH" ]]; then
  fail "Directory not found: $USER_REPO_PATH"
  info "Check the path and run this wizard again."
  abort "Directory not found."
fi

ok "Repo path: $USER_REPO_PATH"

# ── step 6: per-repo acpxrc ───────────────────────────────────────────────────
step 6 "Copying per-repo acpx config to your repo"

ACPXRC_TARGET="$USER_REPO_PATH/.acpxrc.json"

if [[ -f "$ACPXRC_TARGET" ]]; then
  ok "$ACPXRC_TARGET already exists — skipping"
else
  cp configs/.acpxrc.json.example "$ACPXRC_TARGET"
  ok "Copied to $ACPXRC_TARGET"
fi

# Update WORKDIR in .env — handles all special characters in paths
if [[ $PYTHON3_OK -eq 1 ]]; then
  python3 - "$USER_REPO_PATH" << 'PYEOF'
import sys, re
path = sys.argv[1]
content = open('.env').read()
if re.search(r'^WORKDIR=', content, re.MULTILINE):
    content = re.sub(r'^WORKDIR=.*', 'WORKDIR=' + path, content, flags=re.MULTILINE)
else:
    content = content.rstrip('\n') + '\nWORKDIR=' + path + '\n'
open('.env', 'w').write(content)
PYEOF
else
  # awk fallback — safe for special characters
  if grep -q '^WORKDIR=' .env; then
    awk -v p="$USER_REPO_PATH" '/^WORKDIR=/{print "WORKDIR=" p; next}1' \
      .env > .env.tmp && mv .env.tmp .env
  else
    printf '\nWORKDIR=%s\n' "$USER_REPO_PATH" >> .env
  fi
fi
ok "WORKDIR set in .env"

# ── step 7: openclaw config ───────────────────────────────────────────────────
step 7 "Adding claude agent to openclaw config"

blank
warn "SECURITY NOTE — read before continuing"
info ""
info "The next step adds permissionMode: approve-all to your openclaw config."
info "This lets claude code read files, write files, and run shell commands"
info "inside your repo without asking you to approve each one."
info ""
info "This is the right setting when:"
info "  • the repo is yours and you trust it"
info "  • this is your own machine, not a shared server"
info "  • you review results before merging or deploying anything"
info ""
info "To switch to a stricter setting later: see docs/hardening.md"
blank
printf "  Understood — continue? [y/N]: "
read -r _sec_reply
[[ "$_sec_reply" =~ ^[Yy]$ ]] || abort "Setup cancelled at security step."

blank
if [[ $PYTHON3_OK -eq 1 ]]; then
  info "Running automated config merge ..."
  blank
  python3 scripts/merge-openclaw-config.py "$USER_REPO_PATH"
  MERGE_EXIT=$?
  blank
  if [[ $MERGE_EXIT -eq 0 ]]; then
    ok "openclaw config updated"
  elif [[ $MERGE_EXIT -eq 2 ]]; then
    warn "Auto-merge could not parse your openclaw.json."
    info "Add the block shown above to ~/.openclaw/openclaw.json manually."
  else
    warn "Auto-merge failed. Run manually:"
    info "  python3 scripts/merge-openclaw-config.py \"$USER_REPO_PATH\""
  fi
else
  warn "python3 not available — showing manual instructions"
  bash scripts/config-helper.sh "$USER_REPO_PATH"
fi

blank
warn "Restart openclaw now for the config change to take effect."
info "  Manually started:  stop (Ctrl+C) and restart"
info "  pm2:               pm2 restart openclaw"
info "  System service:    check your service manager"
blank
printf "  Press Enter once openclaw is back up..."; read -r

# ── step 8: openclaw login ────────────────────────────────────────────────────
step 8 "Connecting openclaw to your claude auth"

info "Running scripts/login-openclaw-anthropic-cli.sh ..."
blank

if bash scripts/login-openclaw-anthropic-cli.sh; then
  ok "openclaw is now using your local claude auth"
else
  warn "This step had an error."
  info "If openclaw is not running, start it and re-run this wizard."
  info "Or run manually: bash scripts/login-openclaw-anthropic-cli.sh"
fi

# ── step 9: acp doctor ────────────────────────────────────────────────────────
step 9 "Running acp doctor"

blank
bash scripts/acp-doctor.sh || true
blank
info "If errors appeared:"
info "  • Confirm openclaw restarted after the config change"
info "  • Run /acp doctor inside openclaw chat — this often self-repairs"
blank
printf "  Press Enter once /acp doctor is showing healthy..."; read -r

# ── step 10: spawn session ────────────────────────────────────────────────────
step 10 "Spawning the claude session"

blank
printf "${BOLD}  ACTION REQUIRED — do this in openclaw now:${NC}\n"
blank
printf "  Open the telegram topic or openclaw thread you want to use.\n"
printf "  Type this command there:\n"
blank
printf "${BOLD}${GREEN}      /acp spawn claude --bind here${NC}\n"
blank
printf "  This creates a live claude code session bound to that thread.\n"
printf "  All messages sent there will go directly to claude code.\n"
blank
printf "  Press Enter once done..."; read -r

# ── step 11: smoke test ───────────────────────────────────────────────────────
step 11 "Running smoke test"

blank
info "Sending test prompt and checking for expected response ..."
blank

if bash scripts/smoke-test.sh; then
  sep
  blank
  printf "${GREEN}${BOLD}  SETUP COMPLETE${NC}\n"
  blank
  printf "  The bridge is live. What to do next:\n\n"
  printf "  • Send a task from your bound telegram topic or openclaw thread\n"
  printf "  • Or send from the command line:\n\n"
  printf "      bash scripts/dispatch-task.sh examples/tasks/repo-fix.md\n\n"
  printf "  Quick reference for daily commands:  QUICKREF.md\n"
  printf "  Full guide and troubleshooting:      BEGINNER_SETUP.md\n"
  blank
else
  blank
  fail "Smoke test did not return the expected token."
  blank
  info "Check these in order:"
  info "  1.  Did you run /acp spawn claude --bind here in step 10?"
  info "  2.  Was openclaw restarted after the config change in step 7?"
  info "  3.  Run /acp doctor inside openclaw chat and look for errors"
  info "  4.  Run: bash scripts/recover-session.sh — then try again"
  info "  5.  Run: claude auth status --text — confirm still logged in"
  blank
  info "Once fixed: bash scripts/smoke-test.sh"
  blank
  exit 1
fi
