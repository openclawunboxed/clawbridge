# changelog

all notable changes to clawbridge-acp are documented here.
format follows [keep a changelog](https://keepachangelog.com).

---

## [1.1.0] — 2026-04-06

### added
- `BEGINNER_SETUP.md` — plain english setup guide for non-technical operators
- `QUICKREF.md` — one-page daily command reference
- `scripts/setup-guided.sh` — interactive 11-step setup wizard
- `scripts/merge-openclaw-config.py` — automated JSON5 config merger (idempotent, backs up before writing)
- `scripts/config-helper.sh` — config merge helper with manual fallback
- `.gitignore` — prevents `.env`, `proof/`, and backup files from being committed
- `.github/ISSUE_TEMPLATE/bug_report.md` — structured bug report template
- `.github/ISSUE_TEMPLATE/feature_request.md` — structured feature request template
- `CONTRIBUTING.md` — contribution guide

### changed
- `scripts/preflight.sh` — improved error messages with exact fix instructions per failure
- `scripts/smoke-test.sh` — anchored to repo root; improved pass/fail output with five diagnostic steps
- `scripts/validate-local.sh` — checks new files exist; added required-files check; uses python3
- `README.md` — added "start here" section pointing beginners to BEGINNER_SETUP.md; listed new files in repo layout

### fixed
- claude code install command updated from deprecated npm path to native binary installer
- sed WORKDIR substitution replaced with python3/awk to handle special characters in paths
- smoke-test.sh relative path issue fixed (now anchored to repo root)
- node.js prerequisite section clarified — not needed for native binary install

---

## [1.0.0] — initial release

### added
- core acp bridge kit: configs, docs, scripts, prompts, examples
- `docs/architecture.md` — layer diagram
- `docs/auth-and-billing.md` — api key vs cli reuse vs legacy token
- `docs/selection-guide.md` — when to use each path
- `docs/hardening.md` — permission profiles and trust boundaries
- `docs/verification.md` — 5-step checklist
- `docs/failure-recovery.md` — 5 named failure modes with fixes
- `docs/task-contract.md` — required task fields
- `docs/role-walkthrough.md` — solo builder persona walkthrough
- `docs/proof-capture.md` — proof bundle instructions
- `prompts/claude-code-worker.md` — worker system prompt
- `prompts/claude-code-task-envelope.schema.json` — task json schema
- `scripts/preflight.sh`, `validate-local.sh`, `smoke-test.sh`
- `scripts/login-openclaw-anthropic-cli.sh`, `warm-claude-adapter.sh`
- `scripts/dispatch-task.sh`, `dispatch-task-json.sh`
- `scripts/check-session.sh`, `recover-session.sh`
- `scripts/capture-proof.sh`, `acp-doctor.sh`, `print-chat-commands.sh`
- `examples/` — task templates, smoke test, proof examples
- `configs/` — acpx and openclaw config examples
