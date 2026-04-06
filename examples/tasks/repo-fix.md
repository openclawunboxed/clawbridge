objective:
investigate the failing test in this repo and propose the smallest safe patch.

constraints:
- stay inside the current repo
- do not widen scope
- run only the narrowest useful test first
- stop before broad refactors

deliverables:
- summary of the root cause
- files touched
- commands run
- remaining risk
- next best action

review_gate:
-human reviews the diff and the final test output before merge

return_format:
summary:
files:
commands:
risks:
next_action:
