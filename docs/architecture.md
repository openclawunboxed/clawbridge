# architecture

center of the stack

- openclaw in front
- claude code behind it for repo work
- acp between them

where each layer belongs

1. openclaw
- channel transport
- conversation binding
- delivery
- approvals and workflow edges
- memory and operator reach

2. acpx
- structured acp runtime bridge
- persistent sessions
- session status and resume
- typed output instead of terminal scraping

3. claude code
- repo work
- shell work
- test runs
- code reasoning

4. optional operator surfaces
- remote control for continuing one local session from another device
- channels for pushing external events into a running session
- tmux for host-side persistence and visibility
- telegram when you want a phone-first surface

selection rule

if the job is openclaw dispatching code work into claude code, put acp in the middle.

if the job is human continuity from a phone, put tmux, telegram, remote control, or channels above that core.
