# failure recovery

common failures

1. `acpruntimeerror` on write or exec

cause:
- the acpx plugin is still on `permissionMode=approve-reads` with `nonInteractivePermissions=fail`

fix:
- choose the permission profile on purpose
- restart the gateway after changing plugin config
- re-run the smoke test

2. `claude auth status` fails

cause:
- the host running openclaw does not have a live claude login

fix:
- run `claude auth login` on that same host
- if you want openclaw to reuse the local login, run `./scripts/login-openclaw-anthropic-cli.sh`

3. first-run adapter fetch fails

cause:
- no npm access, no network access, or cold caches on first harness use

fix:
- run `./scripts/warm-claude-adapter.sh`
- if that host is locked down, warm the adapter another way before the live spawn

4. session looks stale

cause:
- the named acpx session is closed, dead, or pointing at the wrong repo scope

fix:
- run `./scripts/check-session.sh`
- then run `./scripts/recover-session.sh`

5. wrong path in the middle

cause:
- the cli fallback is healthy, and you think the acp bridge is healthy too

fix:
- verify the bound chat path with `/acp doctor`, `/acp status`, and the smoke token before you trust the first real task
