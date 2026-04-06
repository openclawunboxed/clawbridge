# clawbridge-acp

an acp-first claude code bridge kit for openclaw.

---

## start here

**new to this kit or non-technical:** read [BEGINNER_SETUP.md](BEGINNER_SETUP.md) first.
it walks you from zero to a working bridge with plain english instructions and a single guided wizard.

**already familiar with the stack:** see the fast start section below.

**daily operator commands:** see [QUICKREF.md](QUICKREF.md).

**want to contribute:** see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## what this is

this repo packages the current best-fit pattern for operators who want claude code
doing real repo work behind openclaw:

- **openclaw** as the control layer and front door
- **claude code** as the coding harness
- **acpx** as the structured bridge for persistent claude sessions
- cli fallback as the text-only safety net
- remote control, channels, tmux, and telegram as optional operator lanes

this repo reflects openclaw's current anthropic split:
- api key remains the clearest production path for long-lived gateway hosts
- claude cli reuse on the same host is sanctioned and preferred when available
- legacy anthropic token profiles still work but are not the center of this build

---

## what this repo does

- guided setup wizard that works for non-technical operators
- automated openclaw config merge (json5-aware, idempotent, backs up before writing)
- preflight, smoke test, proof-capture, and session recovery scripts
- task envelope schema and examples for reviewable code work
- role-based walkthrough and selection guide
- per-failure recovery documentation

## what this repo does not do

- replace openclaw or anthropic api keys as the production billing path
- pretend acpx is stable (it is not yet)
- fake a live run inside the repo

---

## fast start

1. install openclaw and claude code on the same host
2. run `claude auth login` on that host
3. run `bash scripts/validate-local.sh`
4. run `bash scripts/preflight.sh`
5. run `bash scripts/login-openclaw-anthropic-cli.sh`
6. run `python3 scripts/merge-openclaw-config.py /path/to/your/repo`
7. restart openclaw
8. run `/acp doctor` inside openclaw chat
9. run `/acp spawn claude --bind here` in the target thread
10. run `bash scripts/smoke-test.sh`

---

## what good looks like

- `claude auth status --text` returns your email
- `openclaw models status` shows a healthy anthropic path
- `/acp doctor` reports the backend as ready
- `/acp spawn claude --bind here` creates a live bound session
- `bash scripts/smoke-test.sh` returns `live-acp-claude-ok`
- `bash scripts/check-session.sh` reports running or reusable (not dead or no-session)
- `bash scripts/capture-proof.sh` writes a timestamped proof bundle

---

## when to use this kit

use it when:
- you want claude code doing real repo work behind openclaw
- you want telegram, discord, or another openclaw channel in front
- you want structured sessions instead of tmux terminal scraping

skip it when:
- you need strict sandbox enforcement for the child runtime
- you want the cleanest production billing path without claude code as the harness
- you only need human continuation into a single local session without openclaw

---

## repo layout

**onboarding**
- BEGINNER_SETUP.md
- QUICKREF.md
- CONTRIBUTING.md

**configs**
- configs/openclaw.acp-agent.fragment.json5.example
- configs/acpx.global.config.json.example
- configs/.acpxrc.json.example

**docs**
- docs/architecture.md
- docs/auth-and-billing.md
- docs/selection-guide.md
- docs/hardening.md
- docs/verification.md
- docs/failure-recovery.md
- docs/task-contract.md
- docs/role-walkthrough.md
- docs/proof-capture.md

**prompts**
- prompts/claude-code-task-envelope.schema.json
- prompts/claude-code-worker.md

**examples**
- examples/chat-commands.txt
- examples/first-task.md
- examples/tasks/smoke-test.md
- examples/tasks/repo-fix.md
- examples/tasks/repo-fix.envelope.json
- examples/proof/healthy-smoke.expected.txt
- examples/proof/permission-trap.expected.txt

**scripts**
- scripts/setup-guided.sh
- scripts/config-helper.sh
- scripts/merge-openclaw-config.py
- scripts/preflight.sh
- scripts/validate-local.sh
- scripts/smoke-test.sh
- scripts/login-openclaw-anthropic-cli.sh
- scripts/warm-claude-adapter.sh
- scripts/dispatch-task.sh
- scripts/dispatch-task-json.sh
- scripts/check-session.sh
- scripts/recover-session.sh
- scripts/capture-proof.sh
- scripts/acp-doctor.sh
- scripts/print-chat-commands.sh

---

## license

mit
