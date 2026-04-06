# role walkthrough

a high-fit first operator for this kit:

a solo builder on a mac mini or linux box who already uses openclaw in telegram.

they want one topic called build queue.

they want to drop repo work from a phone.

they want claude code doing the code work on the host.

they want the result to come back as a reviewable patch summary, not a vague "done."

example loop

1. openclaw stays in front on telegram
2. `/acp spawn claude --bind here` binds the current topic to a claude acp session
3. the operator sends a scoped task from `examples/tasks/repo-fix.md`
4. claude code works inside the repo on the same host
5. the result comes back with:
   - what changed
   - files touched
   - commands run
   - remaining risk
   - next action
6. the operator reviews before merge or external delivery

why this is better than a tmux-first bridge

- the task has a stronger contract
- the output is easier to review
- the control layer stays in openclaw
- the coding harness stays in claude code
- the operator lane is still available when you want it
