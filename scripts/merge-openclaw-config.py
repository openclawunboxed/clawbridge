#!/usr/bin/env python3
"""
merge-openclaw-config.py

Safely merges the clawbridge-acp claude agent config into ~/.openclaw/openclaw.json.

- Handles JSON5 (comments, trailing commas, unquoted keys)
- Makes a timestamped backup before any write
- Idempotent: safe to run more than once
- Falls back to printing manual instructions if the file cannot be parsed

Usage:
    python3 scripts/merge-openclaw-config.py /absolute/path/to/your/repo
"""

import sys
import re
import json
import os
import shutil
from pathlib import Path
from datetime import datetime

CONFIG_PATH = Path.home() / ".openclaw" / "openclaw.json"


def strip_json5(text):
    """
    Convert JSON5 to standard JSON so it can be parsed by json.loads.
    Handles: single-line comments, multi-line comments,
    trailing commas, and unquoted object keys.
    """
    # Remove single-line comments
    text = re.sub(r"//[^\n]*", "", text)
    # Remove multi-line comments
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    # Remove trailing commas before } or ]
    text = re.sub(r",(\s*[}\]])", r"\1", text)
    # Quote unquoted object keys (identifiers not already inside quotes)
    text = re.sub(r'(?<!["\w])([a-zA-Z_$][a-zA-Z0-9_$]*)(\s*:)', r'"\1"\2', text)
    return text


def deep_merge(base, incoming):
    """
    Recursively merge incoming into base.
    For agents.list arrays, appends only if the agent id is not already present.
    """
    result = dict(base)
    for k, v in incoming.items():
        if k in result and isinstance(result[k], dict) and isinstance(v, dict):
            result[k] = deep_merge(result[k], v)
        elif (
            k == "list"
            and isinstance(result.get(k), list)
            and isinstance(v, list)
        ):
            existing_ids = {
                a.get("id") for a in result[k] if isinstance(a, dict)
            }
            for item in v:
                if isinstance(item, dict) and item.get("id") not in existing_ids:
                    result[k].append(item)
                # If already present: skip silently (idempotent)
        else:
            result[k] = v
    return result


def make_inject(repo_path):
    return {
        "agents": {
            "list": [
                {
                    "id": "claude",
                    "runtime": {
                        "type": "acp",
                        "acp": {
                            "agent": "claude",
                            "backend": "acpx",
                            "mode": "persistent",
                            "cwd": repo_path,
                        },
                    },
                }
            ]
        },
        "plugins": {
            "entries": {
                "acpx": {
                    "enabled": True,
                    "config": {
                        "permissionMode": "approve-all",
                        "nonInteractivePermissions": "fail",
                        "pluginToolsMcpBridge": False,
                    },
                }
            }
        },
    }


def show_manual(repo_path):
    inject = make_inject(repo_path)
    print("")
    print("  Could not auto-merge. Add this manually to ~/.openclaw/openclaw.json:")
    print("")
    for line in json.dumps(inject, indent=2).splitlines():
        print("  " + line)
    print("")
    print("  If the file already has an 'agents' block, merge agents.list.")
    print("  If the file already has a 'plugins' block, merge plugins.entries.")
    print("  Do not create duplicate 'agents' or 'plugins' blocks.")


def main():
    if len(sys.argv) < 2:
        print("usage: python3 scripts/merge-openclaw-config.py /path/to/your/repo")
        sys.exit(1)

    repo_path = sys.argv[1]

    if not os.path.isdir(repo_path):
        print(f"error: directory not found: {repo_path}")
        print("Check the path and try again.")
        sys.exit(1)

    inject = make_inject(repo_path)
    CONFIG_PATH.parent.mkdir(parents=True, exist_ok=True)

    # ── no existing config: write fresh ──────────────────────────────────────
    if not CONFIG_PATH.exists():
        CONFIG_PATH.write_text(json.dumps(inject, indent=2) + "\n")
        print(f"  created: {CONFIG_PATH}")
        return

    # ── existing config: backup then merge ───────────────────────────────────
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = CONFIG_PATH.parent / f"openclaw.json.backup-{stamp}"
    shutil.copy2(CONFIG_PATH, backup)
    print(f"  backed up: {backup}")

    raw = CONFIG_PATH.read_text()

    try:
        cleaned = strip_json5(raw)
        existing = json.loads(cleaned)
    except Exception as e:
        print(f"  could not parse existing config: {e}")
        show_manual(repo_path)
        sys.exit(2)

    merged = deep_merge(existing, inject)

    # Check if anything actually changed
    if merged == existing:
        print("  already configured — no changes needed")
        return

    CONFIG_PATH.write_text(json.dumps(merged, indent=2) + "\n")
    print(f"  merged:  {CONFIG_PATH}")
    print("  note: the file is now standard JSON (comments were not preserved).")
    print(f"  your original is safe at: {backup}")


if __name__ == "__main__":
    main()
