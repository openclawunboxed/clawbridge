# quickref

daily commands for clawbridge-acp operators.

---

## chat commands (type in openclaw or telegram)

| command | what it does |
|---|---|
| `/acp doctor` | check the acpx backend is healthy |
| `/acp spawn claude --bind here` | start a claude session bound to this thread |
| `/acp status` | show the current session state |
| `/acp steer tighten scope and continue` | redirect a session that has gone off track |
| `/acp model anthropic/claude-opus-4-6` | switch model for this session |
| `/acp permissions default` | reset permissions to the configured default |
| `/acp timeout 900` | set session timeout to 900 seconds |
| `/acp close` | close the current session |

---

## scripts (run from repo root)

| script | what it does |
|---|---|
| `bash scripts/smoke-test.sh` | confirm the bridge is live |
| `bash scripts/dispatch-task.sh <file>` | send a task file to the current session |
| `bash scripts/dispatch-task-json.sh <file>` | same, but returns structured json |
| `bash scripts/check-session.sh` | show session status and recent history |
| `bash scripts/recover-session.sh` | close and re-create a stale session |
| `bash scripts/acp-doctor.sh` | run acp doctor from the command line |
| `bash scripts/capture-proof.sh` | write a proof bundle with versions and session status |
| `bash scripts/preflight.sh` | verify auth, binaries, and working directory |
| `bash scripts/validate-local.sh` | check the kit itself is intact |

---

## sending a task

paste this into your bound thread, filling in the blanks:

```
objective:
describe what you want done

constraints:
- stay inside the current repo
- do not widen scope

deliverables:
- summary of what changed
- files touched

review_gate:
what you will check before accepting the result

return_format:
summary:
files:
commands:
risks:
next_action:
```

or send from the command line:
```
bash scripts/dispatch-task.sh examples/tasks/repo-fix.md
```

---

## what good looks like

```
claude auth status --text   → logged in as you@example.com
/acp doctor                 → backend: ready
/acp spawn claude           → session created and bound
smoke test                  → live-acp-claude-ok
first real task             → summary / files / commands / risks / next_action
```

---

## common fixes

| symptom | fix |
|---|---|
| smoke test returns nothing | run `/acp spawn claude --bind here` first |
| session write or exec fails | check `permissionMode` in openclaw config — should be `approve-all` for repo work |
| session looks stale | `bash scripts/recover-session.sh` |
| acpx not found | run `/acp doctor` inside openclaw chat |
| claude auth fails | `claude auth login` |

full troubleshooting: `docs/failure-recovery.md`
full beginner guide: `BEGINNER_SETUP.md`
