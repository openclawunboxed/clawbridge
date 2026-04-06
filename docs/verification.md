# verification

what to verify before you trust the bridge

1. host auth exists
- `claude auth status --text` returns success on the same host as the gateway
- `openclaw models status` shows a healthy anthropic path if you expect openclaw to reuse claude cli auth

2. acp backend is ready
- `openclaw acp doctor` or `/acp doctor` reports a healthy acpx backend
- first-run adapter fetches are not failing on that host

3. the bound session is real
- `/acp spawn claude --bind here` succeeds in the thread or topic you care about
- follow-up messages keep landing in the same bound session

4. the smoke token returns
- `./scripts/smoke-test.sh` passes
- or the bound chat returns `live-acp-claude-ok` when you paste `examples/tasks/smoke-test.md`

5. the result shape is reviewable
- the first real task returns a summary, files, commands, risks, and next_action

false positives to watch for

- the acp session spawns, but claude auth is missing on the host
- the session exists, but writes fail because the permission profile was never changed
- the cli fallback is healthy, and you mistake that for the acp harness path being healthy
