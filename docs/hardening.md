# hardening

this kit is not a license to blur trust boundaries.

rules that matter first

- keep claude code on the same host as the repo you intend to work on
- do not widen `cwd` beyond the repo or worktree you mean to touch
- use a dedicated build repo, branch, or worktree when the task has real risk
- treat `pluginToolsMcpBridge` as an explicit expansion of trust, not a free toggle
- remember that acp sessions run on the host, not inside the openclaw sandbox

permission profiles

fast lane
- `permissionMode: approve-all`
- good for trusted repos on your own box when you want the harness to move
- pair this with a narrow `cwd` and human review before merge or deploy

safer lane
- `permissionMode: approve-reads`
- `nonInteractivePermissions: deny`
- good when you want reads and analysis without crashy prompt failures
- this does not fit write-heavy repo work unless you plan for manual escalation

what not to normalize

- `approve-all` on a repo or directory you do not trust
- `pluginToolsMcpBridge: true` without reviewing which plugin tools are already live in the gateway
- tmux capture output as the only audit trail
- one giant shared repo root for unrelated workstreams
