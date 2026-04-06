# selection guide

pick the right path before you wire the stack.

choose acp agents when:
- you want claude code or another coding harness through openclaw
- you need binding, runtime controls, and background-task aware sessions
- you want structured sessions instead of terminal scraping

choose the claude cli backend when:
- you want a conservative local text fallback
- your main goal is local responses with the smallest surface
- you do not need full harness controls

choose remote control when:
- you want to keep steering one local claude code session from another device
- you want the local machine to remain the execution host
- you are fine with claude.ai login requirements and the terminal staying open

choose channels when:
- you want telegram, discord, imessage, or webhooks pushed into a running claude code session
- you want official sender gating and permission relay support
- you accept research-preview constraints and claude.ai login requirements

choose tmux plus telegram when:
- you want phone-first operator continuity
- you want terminal scrollback and reattach
- you understand that tmux is the visible console, not the actual protocol

skip this whole repo when:
- you need openclaw sandbox enforcement for the child runtime
- you want the cleanest production billing path and do not need claude code as the harness
- you only need human continuation and no openclaw layer in the middle
