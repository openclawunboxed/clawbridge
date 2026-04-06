# proof capture

this repo does not ship a fake successful run.

instead, it gives you a repeatable way to capture a real one on your own host.

capture steps

1. finish the smoke test
2. run `./scripts/capture-proof.sh`
3. if you want a machine-readable task log, run:
   `./scripts/dispatch-task-json.sh examples/tasks/repo-fix.md > proof/repo-fix.jsonl`
4. save your openclaw chat transcript or screenshot separately if you need handoff evidence

what gets captured automatically

- openclaw version when available
- claude version
- acpx version when available
- claude auth status
- session status output
- recent session history when available

what you should add manually for a stronger proof bundle

- one screenshot of `/acp doctor`
- one screenshot of the bound chat after the smoke token returns
- one screenshot or pasted diff of the changed files
- one note on whether you used `approve-all` or a stricter permission mode
