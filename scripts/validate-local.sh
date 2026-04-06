#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

GREEN='\033[0;32m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { printf "${GREEN}  ok  %s${NC}\n" "$1"; }
fail() { printf "${RED}  FAIL  %s${NC}\n" "$1"; exit 1; }

# ── 1. bash syntax ────────────────────────────────────────────────────────────
printf "\n${BOLD}bash syntax${NC}\n"
for f in scripts/*.sh; do
  bash -n "$f"
  ok "$f"
done

# ── 2. python3 syntax ─────────────────────────────────────────────────────────
printf "\n${BOLD}python3 syntax${NC}\n"
if command -v python3 >/dev/null 2>&1; then
  python3 -m py_compile scripts/merge-openclaw-config.py
  ok "scripts/merge-openclaw-config.py"
else
  printf "  skipped (python3 not found)\n"
fi

# ── 3. json validity ─────────────────────────────────────────────────────────
printf "\n${BOLD}json validity${NC}\n"
python3 - <<'PY'
import json, sys
from pathlib import Path
files = [
    'configs/acpx.global.config.json.example',
    'configs/.acpxrc.json.example',
    'prompts/claude-code-task-envelope.schema.json',
    'examples/tasks/repo-fix.envelope.json',
]
for rel in files:
    try:
        json.loads(Path(rel).read_text())
        print(f'  ok  {rel}')
    except Exception as e:
        print(f'  FAIL  {rel}: {e}')
        sys.exit(1)
PY

# ── 4. required files exist ────────────────────────────────────────────────────
printf "\n${BOLD}required files exist${NC}\n"
REQUIRED=(
  BEGINNER_SETUP.md
  QUICKREF.md
  CHANGELOG.md
  CONTRIBUTING.md
  .gitignore
  scripts/setup-guided.sh
  scripts/config-helper.sh
  scripts/merge-openclaw-config.py
  .github/ISSUE_TEMPLATE/bug_report.md
  .github/ISSUE_TEMPLATE/feature_request.md
)
for rel in "${REQUIRED[@]}"; do
  [[ -f "$rel" ]] && ok "$rel" || fail "$rel is missing"
done

# ── 5. readme drift ────────────────────────────────────────────────────────────
printf "\n${BOLD}readme drift${NC}\n"
ALL_FILES=(
  BEGINNER_SETUP.md
  QUICKREF.md
  CONTRIBUTING.md
  configs/openclaw.acp-agent.fragment.json5.example
  configs/acpx.global.config.json.example
  configs/.acpxrc.json.example
  docs/architecture.md
  docs/auth-and-billing.md
  docs/selection-guide.md
  docs/hardening.md
  docs/verification.md
  docs/failure-recovery.md
  docs/task-contract.md
  docs/role-walkthrough.md
  docs/proof-capture.md
  prompts/claude-code-task-envelope.schema.json
  prompts/claude-code-worker.md
  examples/chat-commands.txt
  examples/first-task.md
  examples/tasks/smoke-test.md
  examples/tasks/repo-fix.md
  examples/tasks/repo-fix.envelope.json
  examples/proof/healthy-smoke.expected.txt
  examples/proof/permission-trap.expected.txt
  scripts/preflight.sh
  scripts/validate-local.sh
  scripts/smoke-test.sh
  scripts/login-openclaw-anthropic-cli.sh
  scripts/warm-claude-adapter.sh
  scripts/dispatch-task.sh
  scripts/dispatch-task-json.sh
  scripts/check-session.sh
  scripts/recover-session.sh
  scripts/capture-proof.sh
  scripts/acp-doctor.sh
  scripts/print-chat-commands.sh
  scripts/setup-guided.sh
  scripts/config-helper.sh
  scripts/merge-openclaw-config.py
)
for rel in "${ALL_FILES[@]}"; do
  grep -q "$rel" README.md && ok "$rel" || fail "README missing: $rel"
done

printf "\n${GREEN}${BOLD}all checks passed${NC}\n\n"
