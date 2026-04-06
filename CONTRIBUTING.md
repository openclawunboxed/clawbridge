# contributing

contributions are welcome. this is a small, focused repo — keep that spirit.

---

## what belongs here

- fixes to scripts, configs, or docs that are concretely wrong
- improvements to error messages or beginner clarity
- new examples or task templates
- documentation for new openclaw or acpx features as they ship
- validated fixes for failure modes not yet covered in `docs/failure-recovery.md`

## what does not belong here

- large architectural rewrites without prior discussion
- changes that add external dependencies (npm packages, pip packages, etc.)
- openclaw or acpx feature development — those belong in their own repos
- speculative features not yet testable against a real setup

---

## how to contribute

1. fork the repo and create a branch from `main`
2. make your change
3. run `bash scripts/validate-local.sh` — it must pass cleanly
4. test any changed scripts against a real openclaw + claude code setup if possible
5. open a pull request with a clear description of what changed and why

---

## pull request checklist

- [ ] `bash scripts/validate-local.sh` passes
- [ ] all shell scripts pass `bash -n <script>` syntax check
- [ ] all json files are valid (`python3 -c "import json; json.load(open('file'))"`)
- [ ] new files are listed in `README.md` repo layout section
- [ ] new files are added to the readme drift check in `scripts/validate-local.sh`
- [ ] `CHANGELOG.md` has an entry under an appropriate version

---

## reporting bugs

use the bug report template in `.github/ISSUE_TEMPLATE/bug_report.md`.

include:
- output of `bash scripts/capture-proof.sh`
- output of `/acp doctor`
- the exact error message you saw
- what you expected to happen

---

## code style

- shell scripts: bash, `set -euo pipefail`, `shellcheck`-clean where practical
- error messages: plain english, cause first, fix second
- docs: all lowercase, no em dashes, no filler words
- json: 2-space indent

---

## license

by contributing, you agree your contributions are licensed under the same mit license as this project.
