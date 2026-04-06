# beginner setup guide for clawbridge-acp

this guide walks you from zero to a working bridge in plain language.
no prior experience with acp, acpx, or openclaw is needed.

---

## what you are building

you are connecting three tools into one pipeline on a single machine:

```
your phone or computer
        ↓
    openclaw          ← receives your messages and decides what to do with them
        ↓
      acpx            ← keeps a live, persistent session running with claude code
        ↓
  claude code         ← does the actual file reading, writing, and code work
```

when it is working you type a task into telegram (or openclaw directly), claude code
runs it on your machine, and a structured summary comes back to the same chat.

---

## before you start: what you need installed

everything runs on the same machine. that machine can be a mac, a linux box, or windows
running wsl (windows subsystem for linux). the sections below cover all three.

---

### windows users: set up wsl first

if you are on windows, you need wsl. this gives you a linux terminal inside windows
where all the tools can run.

**install wsl:**
open powershell as administrator and run:
```
wsl --install -d Ubuntu
```
this installs ubuntu. restart your machine when asked.

after restarting, open the ubuntu app from the start menu. it will finish setting up
and ask you for a username and password — these are just for ubuntu, not your windows account.

from this point forward, run every command in this guide inside the ubuntu terminal,
not in powershell or cmd.

**find the ubuntu terminal later:**
search for "ubuntu" in the start menu, or look for "windows subsystem for linux" in your apps.

---

### tool 1: claude code

this is anthropic's coding tool. install it inside your terminal:

**mac or linux or wsl:**
```
curl -fsSL https://claude.ai/install.sh | bash
```

after it finishes, reload your shell so the `claude` command becomes available:
```
source ~/.bashrc
```
if you use zsh (common on macs), use this instead:
```
source ~/.zshrc
```

**verify it worked — expected output:**
```
claude --version
```
you should see a version number like `2.x.x`. if you see `command not found`, try
opening a new terminal window and running it again.

**log in:**
```
claude auth login
```
this opens a browser window. sign in with your anthropic account.

**verify login — expected output:**
```
claude auth status --text
```
you should see: `logged in as you@example.com`
if it says not logged in, run `claude auth login` again.

---

### tool 2: openclaw

openclaw is the front door — it handles your telegram or discord messages and routes them
to ai agents. install it following openclaw's official documentation. search "openclaw install"
or check their github page for the current command, as it updates with releases.

**verify it worked:**
```
openclaw --version
```
you should see a version number. if not, make sure you opened a new terminal after installing.

---

### tool 3: acpx

acpx is the bridge layer. it is usually bundled with openclaw — check if it is already there:
```
acpx --version
```
if you see a version number, you are done. if not, run this inside openclaw's chat surface
after openclaw is running and it will repair the path automatically:
```
/acp doctor
```

---

### tool 4: python3

python3 is used to automatically merge the openclaw config file. check if it is already installed:
```
python3 --version
```
you should see `Python 3.x.x`. mac and most linux systems have this already.

if not:
- mac: `brew install python3` (requires homebrew — see https://brew.sh)
- ubuntu / wsl: `sudo apt install python3`

---

## step 1: get the repo

**if you have git:**
```
git clone <this-repo-url> clawbridge-acp
cd clawbridge-acp
```

**if you downloaded a zip:**
unzip it and open a terminal inside the `clawbridge-acp` folder.

on mac you can drag the folder into the terminal to paste its path, then `cd` into it.
on wsl you can right-click the ubuntu terminal titlebar and choose "properties" to check
your current location.

**from this point on, every command in this guide runs from inside the `clawbridge-acp` folder.**

---

## step 2: run the guided setup wizard

the wizard handles every setup step in order. run it now:

```
bash scripts/setup-guided.sh
```

the wizard will:
- detect your operating system (mac, linux, or wsl)
- confirm all four tools above are installed
- verify your claude auth is live
- create your `.env` config file
- copy the right acpx config files to the right places
- ask you for the path to the repo you want claude to work in
- automatically merge the claude agent config into openclaw
- connect openclaw to your local claude login
- run a health check on the acpx backend
- prompt you to spawn a live claude session in your chosen chat thread
- run a smoke test to confirm the full bridge is working

**follow the wizard's prompts from here.** the rest of this guide explains
what each step means in plain language in case you get stuck.

---

## what each step means

### step 1 — checking tools

the wizard checks that `openclaw`, `claude`, `python3`, and `acpx` are findable.

if any are missing it prints the exact install command and stops. fix the missing tool,
open a new terminal, and run the wizard again. it will skip the steps it already completed.

### step 2 — claude auth

the wizard runs:
```
claude auth status --text
```

**expected output when healthy:**
```
logged in as you@example.com
```

if it fails, run `claude auth login` and follow the browser prompt, then run the wizard again.

### step 3 — .env file

the wizard copies `.env.example` to `.env`. this file stores your binary paths and session
settings. the defaults work for most setups. you only need to edit it if your tools are
installed in unusual locations.

### step 4 — global acpx config

the wizard copies `configs/acpx.global.config.json.example` to `~/.acpx/config.json`.

`~` means your home folder: `/Users/yourname` on mac, `/home/yourname` on linux or wsl.

this file tells acpx which agent to use by default and how long to wait before timing out.

### step 5 — your repo path

the wizard asks for the full path to the folder where you want claude to do its work.

this must be a folder that already exists on your machine. examples:
- mac: `/Users/jd/projects/myapp`
- linux: `/home/jd/projects/myapp`
- wsl: `/home/jd/projects/myapp` (the linux path, not `C:\Users\...`)

**tip — mac:** drag the folder into the terminal window to paste its path automatically.
**tip — linux / wsl:** open a terminal in that folder and run `pwd` to see the full path.

### step 6 — per-repo acpx config

the wizard copies `.acpxrc.json.example` into the root of your repo. this tells acpx
which agent and permission settings to use for that specific repo. you do not need to
edit it — the defaults are correct.

### step 7 — openclaw config (with security note)

this is the most important step. the wizard adds a "claude agent" entry to openclaw's
main config file at `~/.openclaw/openclaw.json`.

**before it does this, it shows you a security warning.**

the wizard sets `permissionMode: approve-all`. this means claude code can read files,
write files, and run shell commands inside your repo without asking you to approve each one.

this is the right setting when:
- the repo is yours and you trust what is in it
- this is your own machine, not a shared server
- you plan to review the result before merging or deploying anything

if you want a stricter setting later (where writes are blocked unless you approve them
one by one), read `docs/hardening.md` after setup.

**what the wizard does automatically:**

1. backs up your existing `~/.openclaw/openclaw.json` with a timestamp
2. reads the existing file and strips out json5 syntax (comments, trailing commas)
3. merges the claude agent entry into the `agents.list` array — without touching anything else
4. merges the acpx plugin entry into `plugins.entries` — without touching anything else
5. writes the result back
6. prints `already configured` if it detects the entry is already there (safe to re-run)

if the automatic merge fails because your openclaw.json has unusual formatting, the wizard
falls back to showing you the exact block to paste manually.

**after the merge:** restart openclaw. config changes only take effect after a restart.

### step 8 — connecting openclaw to claude auth

the wizard runs `scripts/login-openclaw-anthropic-cli.sh`. this tells openclaw to reuse
your local claude login for anthropic-backed runs, so you do not need to configure a
separate api key for openclaw to reach claude.

**expected output:**
```
step 1: verify claude auth on this host
logged in as you@example.com

step 2: tell openclaw to reuse the local claude cli login for anthropic
done
```

### step 9 — acp doctor

the wizard runs `/acp doctor` to confirm the acpx backend is healthy.

**expected output when healthy:**
```
backend: ready
sessions: available
```

if it shows errors:
- confirm openclaw was restarted after step 7
- run `/acp doctor` inside the openclaw chat surface — this often repairs the path automatically

### step 10 — spawning the claude session

the wizard pauses and asks you to do one thing manually: go to your openclaw chat
(or telegram topic) and type:
```
/acp spawn claude --bind here
```

this creates a live claude code session connected to that specific thread. once bound,
every message you send in that thread goes directly to claude code.

you only need to do this once per thread. after the bridge is running, the session
persists automatically.

### step 11 — smoke test

the wizard sends the simplest possible task:
```
reply with exactly live-acp-claude-ok
```

**expected output when passing:**
```
live-acp-claude-ok

  ✓  SMOKE TEST PASSED
     The full bridge is live and working.
```

if it fails, the wizard prints five numbered causes to check in order.
the most common cause is that step 10 was skipped — run `/acp spawn claude --bind here`
and then run `bash scripts/smoke-test.sh` to try again.

---

## daily use: sending a task

once the bridge is live, send tasks using the format in `examples/tasks/repo-fix.md`.

copy this template, fill in your details, and paste it into your bound chat thread:

```
objective:
what you want claude to do

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

the folder claude works in is set once during setup — you do not need to repeat it
in every task.

or send a task from the command line:
```
bash scripts/dispatch-task.sh examples/tasks/repo-fix.md
```

**expected return shape:**
```
summary: fixed the null reference in auth.js by adding an early return
files: src/auth.js
commands: npm test -- --grep auth
risks: edge case on line 42 not covered by tests
next_action: human review the diff before merging
```

for daily command reference, see `QUICKREF.md`.

---

## troubleshooting

### "missing openclaw" or "missing acpx"
the terminal cannot find the tool. make sure it is installed and open a new terminal
window — tools installed in the current session are sometimes not available until you restart.

### "claude auth status failed"
you are not logged in. run:
```
claude auth login
```
follow the browser prompt, then run the wizard again.

### smoke test returns nothing or wrong text
the most likely cause: the claude session was not spawned yet.
go to your openclaw chat and run `/acp spawn claude --bind here`, then:
```
bash scripts/smoke-test.sh
```

### first real task fails with a permission error
the permission mode was not set correctly. run:
```
bash scripts/merge-openclaw-config.py /path/to/your/repo
```
then restart openclaw and try again.
full recovery steps are in `docs/failure-recovery.md`.

### session looks stale or dead
```
bash scripts/check-session.sh
bash scripts/recover-session.sh
```
then run `bash scripts/smoke-test.sh` to confirm recovery.

### config merge failed — cannot parse openclaw.json
your openclaw.json has a format the auto-merger could not handle. the wizard will
print the exact block to add manually, and will have made a backup of your original file
before touching anything.

### on wsl: "command not found" after install
the PATH change from the install script only applies to the current terminal session's config file. try:
```
source ~/.bashrc
```
if that does not help, close the ubuntu terminal completely and reopen it.

### something else broke
run:
```
bash scripts/acp-doctor.sh
bash scripts/capture-proof.sh
```
paste both outputs when asking for help. full failure recovery guide: `docs/failure-recovery.md`.

---

## glossary

| word | plain english |
|---|---|
| openclaw | the front door — handles your messages and routes them to agents |
| claude code | the coding tool — reads, edits, and runs code on your machine |
| acpx | the bridge — keeps a live session between openclaw and claude code |
| acp session | a live connection that keeps context between messages |
| smoke test | the simplest possible test — send one line, expect one line back |
| cwd | current working directory — the folder claude is allowed to work inside |
| permissionMode | what claude is allowed to do without asking: `approve-all` means read, write, and run |
| approve-all | the fast lane: claude acts without prompting you for each file or command |
| bound conversation | a chat thread directly connected to a live claude session |
| proof bundle | a file capturing versions and session state as evidence the bridge worked |
| JSON5 | a relaxed version of JSON that allows comments and trailing commas |

---

## you are done when

- `claude auth status --text` shows your email
- `/acp doctor` reports the backend as ready
- `/acp spawn claude --bind here` creates a live session
- `bash scripts/smoke-test.sh` returns `live-acp-claude-ok`
- your first real task returns `summary / files / commands / risks / next_action`

**next:** see `QUICKREF.md` for the daily operator cheat sheet.
