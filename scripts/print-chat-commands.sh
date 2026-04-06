#!/usr/bin/env bash
set -euo pipefail

cat <<'CMDS'
recommended operator commands

/acp doctor
/acp spawn claude --bind here
/acp status
/acp steer tighten scope and continue
/acp close

thread-first variants

/acp spawn claude --thread auto
/acp spawn claude --mode persistent --thread auto

when acp needs tuning

/acp model anthropic/claude-opus-4-6
/acp permissions default
/acp timeout 900
CMDS
