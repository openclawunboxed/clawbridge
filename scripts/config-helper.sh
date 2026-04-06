#!/usr/bin/env bash
# config-helper.sh
# Merges the clawbridge-acp claude agent config into ~/.openclaw/openclaw.json
# Called by setup-guided.sh or usable standalone.
# Usage: bash scripts/config-helper.sh /path/to/your/repo

set -uo pipefail

BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [[ $# -ge 1 && -n "$1" ]]; then
  USER_REPO="$1"
else
  printf "\n${BOLD}Enter the full path to your repo:${NC} "
  read -r USER_REPO
fi

USER_REPO="${USER_REPO/#\~/$HOME}"

if [[ ! -d "$USER_REPO" ]]; then
  printf "Directory not found: %s\n" "$USER_REPO"
  exit 1
fi

printf "\n  Repo path: %s\n\n" "$USER_REPO"

# ── attempt automated merge ───────────────────────────────────────────────────
if command -v python3 >/dev/null 2>&1; then
  printf "${BOLD}  Running automated config merge...${NC}\n\n"
  python3 scripts/merge-openclaw-config.py "$USER_REPO"
  MERGE_EXIT=$?
  if [[ $MERGE_EXIT -eq 0 ]]; then
    printf "\n${GREEN}  Config merged. Restart openclaw for the change to take effect.${NC}\n\n"
    exit 0
  elif [[ $MERGE_EXIT -eq 2 ]]; then
    printf "\n${YELLOW}  Could not auto-merge — use the manual block shown above.${NC}\n\n"
    exit 2
  fi
fi

# ── manual fallback ───────────────────────────────────────────────────────────
OPENCLAW_CONFIG="$HOME/.openclaw/openclaw.json"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ -f "$OPENCLAW_CONFIG" ]]; then
  BACKUP="${OPENCLAW_CONFIG}.backup-${STAMP}"
  cp "$OPENCLAW_CONFIG" "$BACKUP"
  printf "  Backed up to: %s\n\n" "$BACKUP"
  printf "${BOLD}  Your current openclaw.json:${NC}\n\n"
  cat "$OPENCLAW_CONFIG"
  printf "\n\n"
fi

printf "${BOLD}  Add this block to ~/.openclaw/openclaw.json:${NC}\n\n"
cat << FRAGMENT
  agents: {
    list: [
      {
        id: "claude",
        runtime: {
          type: "acp",
          acp: {
            agent: "claude",
            backend: "acpx",
            mode: "persistent",
            cwd: "${USER_REPO}",
          },
        },
      },
    ],
  },

  plugins: {
    entries: {
      acpx: {
        enabled: true,
        config: {
          permissionMode: "approve-all",
          nonInteractivePermissions: "fail",
          pluginToolsMcpBridge: false,
        },
      },
    },
  },
FRAGMENT

printf "\n  Rules: one 'agents' block total, one 'plugins' block total.\n"
printf "  Merge into existing blocks if they are already present.\n"
printf "  Save the file, then restart openclaw.\n\n"

EDITOR_CMD=""
command -v code >/dev/null 2>&1 && EDITOR_CMD="code"
command -v nano >/dev/null 2>&1 && [[ -z "$EDITOR_CMD" ]] && EDITOR_CMD="nano"
command -v vim  >/dev/null 2>&1 && [[ -z "$EDITOR_CMD" ]] && EDITOR_CMD="vim"

if [[ -n "$EDITOR_CMD" ]]; then
  printf "  Open in %s now? [y/N]: " "$EDITOR_CMD"
  read -r _open
  if [[ "$_open" =~ ^[Yy]$ ]]; then
    mkdir -p "$HOME/.openclaw"
    $EDITOR_CMD "$OPENCLAW_CONFIG"
  fi
fi
